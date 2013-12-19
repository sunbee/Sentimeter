# Step I: Clean the corpus for text-mining
#	Supplier: Acquire.R
#   Input:    Corpus of tweeted text, with UTF-8 text removed
#   Process:  Clean up for text-mining analysis
#   Output:   Corpus of tweeted text conditioned for text-mining 
#   Customer: Step II
#   Notes:
#		Removes
#			ampersand, decoded string '&amp'
#			retweets, identfied by 'RT'
#			removes the identifier the tweet is addressed to, using '@'
#			removes url, identfied by 'http://'
#			etc.
source(paste(getwd(), "Sentimeter", "Bin", "cleanText.R" , sep='/'))
cleanText = clean.text(monsanto.clean)

# Step II: Execute text-mining
#	Supplier: Step I
#   Input:    Corpus of tweeted text conditioned for text-mining 
#   Process:  Find word-frequencies
#   Output:   Occurrence of terms
#   Customer: Step III
#   Notes:
#		Collect documents into a corpus. Each line of tweeted text is a document.
#		Analyze to extract word-frequencies. Here, frequecy is calculated for each document.
#			The words from the word-list are rows. The documents are columns.
#			The word-list is extracted from the text. 
#			It is not a std. English-language vocabulary.
#
library(tm)

tweetCorpus = Corpus(VectorSource(cleanText))
tdm = TermDocumentMatrix(tweetCorpus, 
		control = list(
			removePunctuation = TRUE,
			stopwords = c("machine", "learning", stopwords("english")), 
			removeNumbers = TRUE, 
			tolower = TRUE))

# Step III: Plot the word-cloud
#	Supplier: Step II
#   Input:    Occurrence of terms
#   Process:  Extract word-cloud from most frequently occurring terms
#   Output:   The word-cloud
#   Customer: Step IV
#   Notes:
#		
library(wordcloud)
library(RColorBrewer)
require(plyr)
#
m = as.matrix(tdm) 
wordFreqs = sort(rowSums(m), decreasing=TRUE)	# Sort in descending order
dm = data.frame(word = names(wordFreqs), 
		freq = wordFreqs)   					# Set up for plotting
wordcloud(dm$word, dm$freq, 
		random.order = FALSE, 
		colors = brewer.pal(8, "Dark2")) 		# Plot
png("sentiWhy.png", width=12, height=8, units="in", res=300)
dev.off()
#
tweetFreqs = sort(colSums(m), decreasing=TRUE)	# Sort in descending order
lm = data.frame(tweet = names(tweetFreqs), 
		freq = tweetFreqs)    
u = monsanto.clean[head(lm$tweet, n=10)]
write.table(u, file = "foo.csv", sep = ",", col.names = FALSE);