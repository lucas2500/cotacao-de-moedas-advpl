#INCLUDE 'totvs.ch'
#INCLUDE "Protheus.ch"

User Function JobCTCoin()

	Local cMsg        := ""
    Local aGetCotacao := {}

	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv("98", "01")

	aGetCotacao := GetCotacao()

	If aGetCotacao[1]

		cMsg := "<b>COTAÇÃO DE MOEDAS</b>%0A%0A"

		cMsg += "<b>Dólar Americano/Real Brasileiro:</b> R$ " + cValToChar(aGetCotacao[2][1][1]) + "%0A"
		cMsg += "<b>Euro/Real Brasileiro:</b> R$ " + cValToChar(aGetCotacao[2][2][1]) + "%0A"
		cMsg += "<b>Bitcoin/Real Brasileiro:</b> R$ " + cValToChar(aGetCotacao[2][3][1]) + "%0A"

        SendMsg(EncodeUTF8(cMsg))

	Endif

Return

Static Function GetCotacao()

	Local oRequest  := Nil
	Local oJson     := JsonObject():New()
	Local cResponse := ""
	Local cCoinAPI  := ""
	Local cCoins    := ""
	Local cJson     := ""
	Local aRet      := {}

	// Endpoint da API de cotação de moedas
	cCoinAPI := SuperGetMV("VAR_URL", .F., "https://economia.awesomeapi.com.br/last/")

	// Moedas a serem consultadas
	cCoins   := SuperGetMV("VAR_COINS", .F., "USD-BRL,EUR-BRL,BTC-BRL")

	// Requisita a API
	oRequest := FWRest():New(cCoinAPI)
	oRequest:setPath(cCoins)

    // Verifica se o response foi 200 ou 201, conforme documentação da classe
	If oRequest:Get()
        FwLogMsg("INFO", /*cTransactionId*/, "JOBCTCOIN", FunName(), "", "01", "Cotacao de meodas consultada com sucesso!!")
        cResponse := oRequest:GetResult()
	Else
		FwLogMsg("INFO", /*cTransactionId*/, "JOBCTCOIN", FunName(), "", "01", "Houve um erro ao consultar a API de cotacao de moedas")
        Return {.F., aRet}
	Endif

	// Transforma converte o JSON retornado em objeto
	cJson := oJson:FromJson(cResponse)

	// Finaliza a execução caso o ocorra erro no parsing do JSON
	If ValType(cJson) == "C"
		FwLogMsg("INFO", /*cTransactionId*/, "JOBCTCOIN", FunName(), "", "01", "Houve um erro ao parsear o JSON!!")
        Return {.F., aRet}
	Endif

	aAdd(aRet, {Round(Val(oJson["USDBRL"]["bid"]), 2)})
	aAdd(aRet, {Round(Val(oJson["EURBRL"]["bid"]), 2)})
	aAdd(aRet, {Round(Val(oJson["BTCBRL"]["bid"]), 2)})

Return {.T., aRet}

Static Function SendMsg(cMsg)

	Local oRequest  := Nil

    // Endpoint do Telegram
	Local cTelAPI   := SuperGetMV("VAR_TEL", .F., "https://api.telegram.org/")

    // ID do bot do Telegram
	Local BotID     := SuperGetMV("VAR_BOTID", .F., "")
    
    // ID do chat do Telegram
	Local ChatId    := SuperGetMV("VAR_CHAT", .F., "")

	oRequest := FWRest():New(cTelAPI)
	oRequest:setPath("bot" + BotID + "/sendMessage" + "?chat_id=" + ChatId + "&text=" + cMsg + "&parse_mode=html")

	If oRequest:Get()
		FwLogMsg("INFO", /*cTransactionId*/, "JOBCTCOIN", FunName(), "", "01", "Notifcacao enviada para o Telegram!!")
    Else
        FwLogMsg("INFO", /*cTransactionId*/, "JOBCTCOIN", FunName(), "", "01", "Houve um erro ao enviar a notificacao para o Telegram!!")
    Endif

Return 
