# config.ru
$LOAD_PATH.unshift('./lib')
require "proctoru_client"
require "proctoru_client/test_api_server"

run ProctoruClient::TestApiServer
