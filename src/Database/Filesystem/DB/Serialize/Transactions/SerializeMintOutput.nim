#Errors lib.
import ../../../../../lib/Errors

#Util lib.
import ../../../../../lib/Util

#MinerWallet lib.
import ../../../../../Wallet/MinerWallet

#MintOutput object.
import ../../../../../Database/Transactions/objects/TransactionObj

#Common serialization functions.
import ../../../../../Network/Serialize/SerializeCommon

#Serialization function.
proc serialize*(
    output: MintOutput
): string {.inline, forceCheck: [].} =
    result =
        output.key.toString() &
        output.amount.toBinary().pad(INT_LEN)
