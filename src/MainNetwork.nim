include MainPersonal

proc mainNetwork() {.forceCheck: [].} =
    {.gcsafe.}:
        #Create the Network..
        network = newNetwork(NETWORK_ID, NETWORK_PROTOCOL, functions)

        #Start listening.
        try:
            asyncCheck network.listen(config)
        except Exception:
            discard

        #Handle network events.
        #Connect to another node.
        functions.network.connect = proc (
            ip: string,
            port: int
        ) {.forceCheck: [
            ClientError
        ], async.} =
            try:
                await network.connect(ip, port)
            except ClientError as e:
                raise e
            except Exception as e:
                doAssert(false, "Couldn't connect to another node due to an exception thrown by async: " & e.msg)

        #Broadcast a message.
        functions.network.broadcast = proc (
            msgType: MessageType,
            msg: string
        ) {.forceCheck: [].} =
            try:
                asyncCheck network.broadcast(
                    newMessage(
                        msgType,
                        msg
                    )
                )
            except Exception as e:
                doAssert(false, "Couldn't broadcast a message due to an exception thrown by async: " & e.msg)
