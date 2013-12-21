fetch.tweets <- function(term, n) {
	out <- tryCatch(
		{
			monsanto.tweets <- searchTwitter(term, n = 6000);
			# This is the return value
			save(m, file = 'monsanto.tweets.RData');
			return(monsanto.tweets);

		},
		error = function(e) {
			load(paste(getwd(), "/Sentimeter/lib/monsanto.tweets.RData", sep = ""));
			return(monsanto.tweets);
			message("FAILED querying Twitter REST API.");
			message(paste("System REPORTED error as: ", e));
			message("LOADED tweets archived on disk to recover.");
		},
		warning = function (w) {
			message("ENCOUNTERED bump querying Twitter REST API.");
			message(paste("System WARNED that: ", w));
		},
		finally = {
			message("COMPLETED process to acquire tweets.");
		}
	);
};
