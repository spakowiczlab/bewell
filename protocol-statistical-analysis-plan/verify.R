# Only retained manuscript methods; synthetic fixtures stay in memory.
source('manuscript_methods.R')
invisible(parse('manuscript_methods.R'))
for(file in list.files(pattern='[.]Rmd$')) {
 code<-knitr::purl(file,output=tempfile(fileext='.R'),quiet=TRUE)
 invisible(parse(code));unlink(code)
}
a<-data.frame(subject=c('B','A','A'),feature=c('x','y','x'),value=c(3,2,1))
M<-make_matrix(a,'subject','feature','value')
stopifnot(M['A','x']==1,M['B','x']==3,is.na(M['B','y']))
stopifnot(inherits(try(make_matrix(rbind(a,a[1,]),'subject','feature','value'),silent=TRUE),'try-error'))
# Pair on participant IDs rather than row order.
x<-data.frame(Subject.Number=c('B','A','A','B'),metabolite='test',
 Timepoint=c('tB','rB','tB','rB'),value=c(7,2,5,1))
w<-paired_visit(x,'metabolite')
stopifnot(w$change[w$Subject.Number=='A']==3,w$change[w$Subject.Number=='B']==6)
# The final source median score supersedes the earlier hclust labels.
met<-expand.grid(Subject.Number=as.character(1:4),metabolite=c('a','b'),
 Timepoint=c('rB','tB'),stringsAsFactors=FALSE)
met$value<-ifelse(met$Timepoint=='rB',0,as.numeric(met$Subject.Number)*ifelse(met$metabolite=='a',1,2))
tests<-data.frame(metabolite=c('a','b'),treatment='BRB',p=c(.01,.02))
r<-responder_score(met,tests)
stopifnot(all(r$BRB_response[r$subject %in% c('1','2')]=='Non-responder'),
 all(r$BRB_response[r$subject %in% c('3','4')]=='Responder'))
# Pseudocount-inclusive >=2 rule, including exact equality.
rel<-data.frame(Subject.Number=c('A','A','B','B'),variable=c('rB','tB','rB','tB'),
 Taxonomy='k__Bacteria|g__target',RelAbun=c(0,1e-6,1,1))
model<-data.frame(term='g__target',p.value=.01)
g<-microbiome_groups(rel,model)
stopifnot(as.character(g$brb_status[g$Subject.Number=='A'])=='altered by BRB',
 as.character(g$brb_status[g$Subject.Number=='B'])=='not altered by BRB')
cat('Retained notebook/helper parse; matrix, pairing and response-rule checks pass.\n')
