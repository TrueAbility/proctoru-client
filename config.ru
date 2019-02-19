# config.ru
$LOAD_PATH.unshift('./lib')
require "examity_client"
require "examity_client/test_api_server"

run ExamityClient::TestApiServer
