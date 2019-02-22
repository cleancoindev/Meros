#Hash lib.
import ../../../lib/Hash

#Entry object.
import EntryObj

#Finals lib.
import finals

#Data object.
finalsd:
    type Data* = ref object of Entry
        #Data included in the Entry.
        data* {.final.}: string

        #Proof this isn't spam.
        proof* {.final.}: uint
        #Argon hash.
        argon* {.final.}: ArgonHash

#New Data object.
func newDataObj*(data: string): Data {.raises: [FinalAttributeError].} =
    result = Data(
        data: data
    )
    result.ffinalizeData()

    result.descendant = EntryType.Data
