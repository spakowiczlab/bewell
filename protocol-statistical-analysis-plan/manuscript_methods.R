# Operational methods from manuscript/scripts, inspected 8 October 2026.
# Original notebooks are not modified. All outputs go to an ignored directory.
# These methods are a retrospective implementation record, not proof of preplanning.
need_manuscript <- function(pkg) {
  if(!requireNamespace(pkg,quietly=TRUE))stop('Missing package: ',pkg)
}
read_repo_csv <- function(path,...)read.csv(file.path(manuscript_cfg$data_dir,path),check.names=FALSE,...)
write_manuscript <- function(x,name)write.csv(x,file.path(manuscript_cfg$output_dir,name),row.names=FALSE)
# IDs are checked in this repository's numeric participant namespace, not reidentified.
participant_key <- function(x)as.character(as.integer(as.character(x)))
make_matrix <- function(long,id,feature,value,fill=NA_real_) {
  if(anyDuplicated(paste(long[[id]],long[[feature]],sep='::')))stop('Duplicate matrix cell.')
  ids<-unique(as.character(long[[id]]));features<-unique(as.character(long[[feature]]))
  m<-matrix(fill,length(ids),length(features),dimnames=list(ids,features))
  m[cbind(match(as.character(long[[id]]),ids),match(as.character(long[[feature]]),features))]<-long[[value]]
  m
}
paired_visit <- function(long,feature,group_col='Timepoint',value_col='value',id_col='Subject.Number',
                         pre='rB',post='tB') {
  a<-long[long[[feature]] %in% unique(long[[feature]])&long[[group_col]]==pre,c(id_col,feature,value_col)]
  b<-long[long[[group_col]]==post,c(id_col,feature,value_col)]
  names(a)[ncol(a)]<-'pre';names(b)[ncol(b)]<-'post'
  if(anyDuplicated(a[,c(id_col,feature)])||anyDuplicated(b[,c(id_col,feature)]))stop('Duplicate pre/post row.')
  w<-merge(a,b,by=c(id_col,feature),all=TRUE,sort=FALSE);w$change<-w$post-w$pre;w
}
metabolite_data <- function(clinical) {
  need_manuscript('readxl');need_manuscript('tidyr');need_manuscript('dplyr')
  # Literal inclusion/zero-conversion rules from metabolites_bewell.Rmd.
  x<-as.data.frame(readxl::read_excel(file.path(manuscript_cfg$data_dir,
    'raw/urine-metabolomics/Dan Urine Anthocyanin 11-10-2022.xlsx'),sheet='concentration ng mL'))
  if(!'21-V2' %in% names(x)||ncol(x)<81)stop('Worksheet contract differs from source notebook.')
  x<-x[!is.na(x[['21-V2']]),];names(x)[1]<-'metabolite'
  for(j in seq.int(2,ncol(x))) {x[[j]]<-as.numeric(x[[j]]);x[[j]][is.na(x[[j]])]<-0}
  x<-tidyr::pivot_longer(x,cols=2:81,names_to='Sample',values_to='value')
  x$Subject.Number<-sub('-.*','',x$Sample);x$v<-toupper(sub('^[^-]*-','',x$Sample))
  k<-clinical$samples_long
  k$v<-toupper(substr(k$timepoints,11,12));k$v<-ifelse(k$v=='-V',toupper(substr(k$timepoints,12,13)),k$v)
  k$Subject.Number<-as.character(k$Subject.Number)
  k<-k[,c('Subject.Number','v','Timepoint')]
  if(anyDuplicated(k[complete.cases(k[,c('Subject.Number','v')]),c('Subject.Number','v')]))stop('Duplicate sample key.')
  # Left join deliberately retains unmatched visits for an explicit exclusion audit.
  out<-dplyr::left_join(x,k,by=c('Subject.Number','v'))
  write_manuscript(as.data.frame(out[is.na(out$Timepoint),]),'metabolite_unmatched_visits.csv')
  as.data.frame(out[!is.na(out$Timepoint),])
}
metabolite_tests <- function(met) {
  output<-list()
  for(tr in c('BRB','placebo')) {
    w<-paired_visit(met,'metabolite',pre=if(tr=='BRB')'rB' else 'rP',post=if(tr=='BRB')'tB' else 'tP')
    rows<-lapply(split(w,w$metabolite),function(a) {
      a<-a[is.finite(a$pre)&is.finite(a$post),]
      test<-tryCatch(wilcox.test(a$pre,a$post,paired=TRUE),error=function(e)NULL)
      data.frame(metabolite=if(nrow(a))a$metabolite[1] else NA_character_,treatment=tr,n_pairs=nrow(a),
        mean_post_minus_pre=if(nrow(a))mean(a$change) else NA_real_,
        p=if(is.null(test))NA_real_ else test$p.value)
    })
    res<-do.call(rbind,rows)
    # BH is coded for BRB tests. A placebo BH calculation would be a new addition.
    res$BH_p<-if(tr=='BRB')p.adjust(res$p,method='BH') else NA_real_
    output[[tr]]<-res
  }
  do.call(rbind,output)
}
responder_score <- function(met,tests) {
  selected<-tests$metabolite[tests$treatment=='BRB'&!is.na(tests$p)&tests$p<.05]
  w<-paired_visit(met,'metabolite');w<-w[w$metabolite %in% selected,]
  M<-make_matrix(w,'Subject.Number','metabolite','change');Z<-scale(M)
  # Final exported source uses the median of each subject's mean z-score,
  # replacing the earlier hierarchical clustering labels in that source notebook.
  score<-rowMeans(Z,na.rm=TRUE);cut<-median(score,na.rm=TRUE)
  data.frame(subject=rownames(Z),poly_score=score,
             BRB_response=ifelse(score>=cut,'Responder','Non-responder'))
}
cytokine_data <- function(clinical) {
  x<-read_repo_csv('derived/cytokines_avg-results.csv')
  x$Sample<-sub('^0','',sub('[.]1$','',x$Sample))
  s<-clinical$samples;mapping<-lapply(seq_len(nrow(s)),function(i) {
    # Source mapping uses nominal visit indices and sequence, not concentration.
    indices<-if(s$placebo[i]=='Week 0')c(3,4,1,2) else c(1,2,3,4)
    data.frame(Sample=paste(s$Subject.Number[i],indices,sep='-'),
               timepoint.label=c('preBRB','postBRB','preP','postP'))
  })
  key<-do.call(rbind,mapping)
  if(anyDuplicated(key$Sample))stop('Duplicate cytokine sample mapping.')
  x<-merge(x,key,by='Sample',all.x=TRUE,sort=FALSE)
  x$subject<-sub('-.*','',x$Sample);x$post_brb<-as.integer(x$timepoint.label=='postBRB')
  write_manuscript(x[is.na(x$timepoint.label),],'cytokine_unmatched_samples.csv')
  x
}
cytokine_glmm <- function(cyto,analytes,responder_ids=NULL) {
  need_manuscript('lme4')
  x<-cyto[cyto$timepoint.label %in% c('preBRB','postBRB'),]
  if(!is.null(responder_ids))x<-x[x$subject %in% responder_ids,]
  rows<-lapply(analytes,function(f) {
    a<-x[x$cytokine==f & is.finite(x$avg.res),];a$subject<-factor(a$subject)
    row<-data.frame(analyte=f,n_records=nrow(a),n_subjects=length(unique(a$subject)),
      estimate=NA_real_,std_error=NA_real_,z=NA_real_,p=NA_real_,
      singular=NA,status='unavailable',warning='')
    warnings<-character()
    fit<-tryCatch(withCallingHandlers(lme4::glmer(post_brb~avg.res+(1|subject),data=a,family=binomial),
      warning=function(w){warnings<<-c(warnings,conditionMessage(w));invokeRestart('muffleWarning')}),
      error=function(e){row$status<<-conditionMessage(e);NULL})
    if(!is.null(fit)) {
      co<-coef(summary(fit))['avg.res',];row[,c('estimate','std_error','z','p')]<-co
      row$singular<-lme4::isSingular(fit);row$status<-'fitted'
      warnings<-c(warnings,unlist(fit@optinfo$conv$lme4$messages))
      saveRDS(fit,file.path(manuscript_cfg$output_dir,paste0('cytokine_',make.names(f),
        if(is.null(responder_ids))'_all' else '_responders','.rds')))
    }
    row$warning<-paste(unique(warnings),collapse='; ');row
  })
  do.call(rbind,rows)
}
rank_tables <- function() {
  ranks<-c('king','phyl','class','ord','fam','gen','spec')
  tables<-lapply(ranks,function(rank)read_repo_csv(paste0('derived/RelAbun/RelAbun_',rank,'.csv'),row.names=1))
  names(tables)<-ranks
  reference<-rownames(tables[[1]])
  if(any(!vapply(tables,function(x)identical(rownames(x),reference),logical(1))))
    stop('Rank-table row order differs; source cbind cannot be reproduced safely.')
  tables
}
taxon_glm <- function(tables) {
  # Literal active conrad fig4B implementation: tB versus all other labels;
  # no random intercept, pair restriction, BH or >20% prevalence selection.
  rows<-list()
  for(rank in names(tables)) {
    a<-tables[[rank]];post<-as.integer(grepl('tB',rownames(a)))
    for(f in names(a)) {
      result<-data.frame(rank=rank,feature=f,n=nrow(a),estimate=NA_real_,std_error=NA_real_,
                         z=NA_real_,p=NA_real_,status='unavailable')
      fit<-tryCatch(glm(post~value,data=data.frame(post=post,value=a[[f]]),family=binomial),
                    error=function(e){result$status<<-conditionMessage(e);NULL})
      if(!is.null(fit)) {
        co<-coef(summary(fit))
        if('value' %in% rownames(co)) {result[,c('estimate','std_error','z','p')]<-co['value',];result$status<-'fitted'}
        result$n<-nobs(fit)
      }
      rows[[length(rows)+1]]<-result
    }
  }
  do.call(rbind,rows)
}
# Source Simpson tests are unpaired Welch, despite manuscript paired-test wording.
simpson_source <- function(tables) {
  need_manuscript('vegan');m<-as.matrix(do.call(cbind,tables));a<-vegan::diversity(m,index='simpson')
  data.frame(sample=rownames(m),timepoint=sub('.*-','',rownames(m)),Simpson=as.numeric(a))
}
microbiome_groups <- function(rel,model_results) {
  # Saved model_results source formula unresolved. Do not substitute the active GLM.
  selected<-unique(model_results$term[!is.na(model_results$p.value)&model_results$p.value<.05])
  rel$term<-sub('.*[|]','',rel$Taxonomy)
  a<-rel[rel$term %in% selected & rel$variable %in% c('rB','tB'),]
  total<-aggregate(RelAbun~Subject.Number+variable,a,sum,na.rm=TRUE)
  names(total)[names(total)=='variable']<-'Timepoint';names(total)[names(total)=='RelAbun']<-'value'
  total$feature<-'selected_total';w<-paired_visit(total,'feature')
  w<-w[is.finite(w$pre)&is.finite(w$post),];w$fold_change<-(w$post+1e-6)/(w$pre+1e-6)
  w$brb_status<-factor(ifelse(w$fold_change>=2,'altered by BRB','not altered by BRB'),
                       levels=c('not altered by BRB','altered by BRB'))
  w
}
base_microbiome_matrix <- function(rel,subjects,visit) {
  rel$term<-sub('.*[|]','',rel$Taxonomy)
  a<-rel[rel$variable==visit & rel$Subject.Number %in% subjects,c('Subject.Number','term','RelAbun')]
  if(visit=='tB')a<-aggregate(RelAbun~Subject.Number+term,a,sum,na.rm=TRUE)
  # Fill 0 is the exact matrix-pivot choice, not missing clinical sample imputation.
  make_matrix(a,'Subject.Number','term','RelAbun',fill=0)
}
