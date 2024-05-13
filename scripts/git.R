#Code for setting and updating GitHub Credentials
#https://happygitwithr.com/https-pat

library(gitcreds)

#Run this, will show you current credetnials and give you an option to update it
gitcreds_set()

#Run this to check you've stored a token. Should say username: PersonalAccessToken, password: hidden
gitcreds_get()
