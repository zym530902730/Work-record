rm(list=ls())
# 读取fasta文件
eq_import <- function( file ){
    seq <- readLines(file) # 读入序列，每个元素存入一行
    seq <- seq[seq != ""] # 去除空行
    is.anno <- regexpr("^>", seq, perl=T) # 正则匹配（regular expression）注释行,是注释行为1，否则为-1
    seq.anno <- seq[ which(is.anno == 1) ] # 注释内容
    seq.content <- seq[ which(is.anno == -1) ] # 序列内容
    ##--计算每条序列内容所占的行数，便于后来拼接--##
    start <- which(is.anno == 1) # 注释行行号
    end <- start[ 2:length(start) ]-1 # 第二条记录注释行到最后一条记录注释行行号减一，即为每条记录结束行号，这里会统计少一行——最后一行的结束未统计
    end <- c(end, length(seq) ) # 末尾添加一行：所有序列结束行
    distance <- end - start # 每条记录所占行号
    index <- 1:length(start) # 生成一个一到记录总个数的向量
    index <- rep(index, distance) # 分组标签
    seqs <- tapply(seq.content, index, paste, collapse="") # 拼接每条序列内容，返回一个列表，列表每个元素为一条序列的内容
    seq.content<-as.character( seqs ) # 将列表转换为向量，向量每个元素为一条序列的内容
    seq.len <- nchar(seq.content) # 获得序列长度
    seq.ID <- gsub("^>(\\w+\\|){3}([A-Za-z0-9.]+)\\|.*", "\\2", seq.anno, perl = T) # 获取序列的ID
    result <- data.frame( seq.ID, seq.anno, seq.len, seq.content ) # 组件结果：ID，长度，注释行，序列内容
    result # 最后一行作为返回值
}





textdata <- read.table("/Users/yimingzhao/Desktop/rawdatafile/Protein.txt", na.strings = "NA", sep = "\t",
                       check.names = FALSE, fill = TRUE, header = TRUE,
                       stringsAsFactors = FALSE)

f = eq_import("/Users/yimingzhao/Desktop/rawdatafile/uniprot-human-filtered-reviewed%3Ayes.fasta")

f = f[,-2]
f[,1]=as.vector(f[,1])
f[,3]=as.vector(f[,3])

for (i in 1:nrow(textdata)) {
    for (j in 1:nrow(f)) {
        if(grepl(textdata$`Protein accession`[i],f[j,1],fixed = TRUE)){
            seq <- f$seq.content[j]
            len = nchar(seq)
            #print(seq)
            if(textdata$Position[i] - 50>=0 && textdata$Position[i]+50<=len){
                seq = substr(seq,textdata$Position[i] -50,textdata$Position[i] +50)
            }
            if(textdata$Position[i] - 50<0 && textdata$Position[i]+50<=len){
                seq = substr(seq,0,textdata$Position[i] +50)
                for (t in 1:(51-textdata$Position[i])) {
                    seq = paste("_",seq,sep = "")
                }
                
            }
            if(textdata$Position[i] + 50>len && textdata$Position[i] - 50>=0){
                seq = substr(seq,textdata$Position[i]-50,len)
                for (t in 1:(50-(len - textdata$Position[i]))){
                    seq = paste(seq,"_",sep = "")
                }
            }
            
            if(textdata$Position[i] - 50<0 && textdata$Position[i]+50>len){
                seq = substr(seq,0,len)
                for (t in 1:(51-textdata$Position[i])) {
                    seq = paste("_",seq,sep = "")
                }
                for (t in 1:(50-(len - textdata$Position[i]))) {
                    seq = paste(seq,"_",sep = "")
                }
            }
            print(seq)
            textdata$seq[i] = seq
        }
    }
}



textdata[,1] = as.vector(textdata[,1])
textdata51 = textdata
write.csv(textdata51,file = "/Users/yimingzhao/Desktop/Pdata1_101.csv",fileEncoding = "UTF-8",quote = FALSE)
             


# textdata2 存储匹配序列信息
textdata2 = data.frame("",1,"")
colnames(textdata2)=c("Protein accession","Position","seq")


textdata2[,1] = as.vector(textdata2[,1])
textdata2[,2] = as.numeric(textdata2[,2])
textdata2[,3] = as.vector(textdata2[,3])
sum=1
for (i in 1:nrow(textdata)) {
    for (j in 1:nrow(f)) {
        if(grepl(textdata$`Protein accession`[i],f[j,1],fixed = TRUE)){
            for (index in 1:nchar(f$seq.content[j])) {
                if(index!= textdata$`Protein accession`[i] && substr(f$seq.content[j],index,index)=="K"){
                    seq <- f$seq.content[j]
                    len = nchar(seq)
                    #print(seq)
                    if(index - 50>=0 && index+50<=len){
                        seq = substr(seq,index -50,index +50)
                    }
                    if(index - 50<0 && index+50<=len){
                        seq = substr(seq,0,index +50)
                        for (t in 1:(51-index)) {
                            seq = paste("_",seq,sep = "")
                        }
                    }
                    if(index + 50>len && index - 50>=0){
                        seq = substr(seq,index-50,len)
                        for (t in 1:(50-(len - index))) {
                            seq = paste(seq,"_",sep = "")
                        }
                    }
                    
                    if(index - 50<0 && index+50>len){
                        seq = substr(seq,0,len)
                        for (t in 1:(51-index)) {
                            seq = paste("_",seq,sep = "")
                        }
                        for (t in 1:(50-(len - index))) {
                            seq = paste(seq,"_",sep = "")
                        }
                    }
                    print(sum)
                    print(seq)
                    textdata2[sum,1] <- textdata$`Protein accession`[i]
                    textdata2[sum,2] <- index
                    textdata2[sum,3] <- seq
                    sum <- sum+1
                }
            }
            
        }
    }
}

write.csv(textdata2,file = "/Users/yimingzhao/Desktop/Ndata1_101.csv",fileEncoding = "UTF-8",quote = FALSE)


