# Step I: Authenticate the application 
#	Supplier: None
#   Input:    None
#   Process:  Authenticate user/application to access Twitter REST API 1.1
#   Output:   Authenticated Application
#   Customer: Step II
#   Notes:
#		Twitter REST API 1.1 requires an authenticated user or application.
#		Go to dev.twitter.com and https://dev.twitter.com/apps
#		Click on an application from among the apps.
#		Supply the information below: consumerKey, consumerSecret
#
require(twitteR);
require(ROAuth);
require(stringr);
require(plyr);
library(RCurl);

options(RCurlOptions = list(cainfo = system.file('CurlSSL', 'cacert.pem', package = 'RCurl')));
reqURL <- "https://api.twitter.com/oauth/request_token";
accessURL <- "http://api.twitter.com/oauth/access_token";
authURL <- "http://api.twitter.com/oauth/authorize";
 
consumerKey <- "Put your data in Bin/twitterKeys.R";
consumerSecret <- "Put your data in Bin/twitterKeys.R";
source(paste(getwd(), "Sentimeter", "Bin", "twitterKeys.R" , sep='/'))
 
twitCred <- OAuthFactory$new(
			consumerKey		= consumerKey,
			consumerSecret	= consumerSecret,
			requestURL		= reqURL,
			accessURL		= accessURL,
			authURL			= authURL);
 
download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem");
twitCred$handshake(cainfo="cacert.pem")
registerTwitterOAuth(twitCred)

# Step II: Clean up the data
#	Supplier: Step I
#   Input:    Authenticated Application
#   Process:  Clean up the returned R object (list of objects of class 'status') and extract text
#   Output:   Corpus of tweeted text - on disk (file) and memory (list)
#   Customer: Step III
#   Notes:
#		Refer TwitteR documentation on object of class 'status' - data and methods
#		Use 'status' to extract: id, text, created, etc.
#
require(plyr)
source(paste(getwd(), "Sentimeter", "Bin", "fetchTweets.R" , sep='/'))

myTerm = '@monsanto'; myNo = 6000;
monsanto.tweets <- fetch.tweets(myTerm, myNo);

monsanto.text = laply(monsanto.tweets, function(t) t$getText());
monsanto.clean = monsanto.text[Encoding(monsanto.text) != "UTF-8"];
w = ldply(monsanto.tweets, function(x) data.frame(as.character(x$id), x$text, x$created))
write.table(w, file = "bar.csv", sep = ",", col.names = FALSE);

# Observed uneven performance with:
#
#	monsanto.tweets = searchTwitter('@monsanto', n = 6000);
#	monsanto.tweets.20131207 = searchTwitter('@monsanto', n = 6000, until = '2013-12-07');
#	monsanto.tweets.20131205 = searchTwitter('@monsanto', n = 6000, until = '2013-12-05');
#	monsanto.tweets.20131202 = searchTwitter('@monsanto', since = '2013-12-02', until = '2013-12-02', lang = 'en');
#	monsanto.tweets.20131130 = searchTwitter('@monsanto', n = 1500, until = '2013-11-30');
#	monsanto.tweets.20131130.en = searchTwitter('@monsanto', until = '2013-11-30', lang = 'en');
#	monsanto.tweets.20131130.en.20 = searchTwitter('@monsanto', until = '2013-11-30', n=20, lang = 'en');

# Step III: Analyze sentiment
#	Supplier: Step II, Standard Sentiment Vocabularies
#   Input:    Corpus of tweeted text
#   Process:  Execute Sentiment Analysis
#   Output:   Sentiment Histogram
#   Customer: Step IV, Analyze.R
#   Notes:
#		Sentiment Vocabularies: http://www.cs.uic.edu/~liub/FBS/sentiment-analysis.html
#
source(paste(getwd(), "Sentimeter", "Bin", "SentiScore.R" , sep='/'))
pos.words = scan('C:/Documents and Settings/ssbhat3/Desktop/Org Docs/Innovation/TwitteR/positive-words.txt', what='character', comment.char=';')
neg.words = scan('C:/Documents and Settings/ssbhat3/Desktop/Org Docs/Innovation/TwitteR/negative-words.txt', what='character', comment.char=';')

monsanto.score = score.sentiment(monsanto.clean, pos.words, neg.words, .progress = 'text'); 
hist(monsanto.score$score)
table(monsanto.score$score)
median(monsanto.score$score)

# Step IV: Visualize sentiment
#	Supplier: Step III
#   Input:    Sentiment Scores
#   Process:  Visualize - Trends and Snapshop
#   Output:   How is sentiment trending? 
#   Customer: Analyze.R
#   Notes:
#		Show 'How' sentiment is trending with bar-plot, 
#			showing the proportion of +ve (blue) and -ve (red) tweets,
#			by count
#		Use cross-tabulation with 'table' to obtain
#			the count by category
#		Render pie-chart on the whole set
#
s <- monsanto.score$score;
f <- factor(sort(rep(1:15, len = length(monsanto.score$score))))
tapply(s, f, sum)
p <- tapply(s, f, function(x) {length(x[x<0])/length(x)});
barplot(table(s<0, f), col=c("darkblue","red"), xlab="days")
pie(table(s), col=rainbow(7))
