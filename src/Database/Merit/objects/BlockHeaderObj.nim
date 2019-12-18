#Errors lib.
import ../../../lib/Errors

#Util lib.
import ../../../lib/Util

#Hash lib.
import ../../../lib/Hash

#MinerWallet lib.
import ../../../Wallet/MinerWallet

#SerializeCommon lib.
import ../../../Network/Serialize/SerializeCommon

#Finals lib.
import finals

finalsd:
    type BlockHeader* = ref object
        #Version.
        version* {.final.}: uint32
        #Hash of the last block.
        last* {.final.}: ArgonHash
        #Merkle of the contents.
        contents*: Hash[384]

        #Amount of Merit required for a Transaction to be included.
        significant*: uint16
        #Salt used when hasing sketch elements in order to avoid collisions.
        sketchSalt*: string
        #Merkle of the included sketch hashes.
        sketchCheck*: Hash[384]

        #Miner.
        case newMiner*: bool
            of true:
                minerKey* {.final.}: BLSPublicKey
            of false:
                minerNick* {.final.}: uint16
        #Timestamp.
        time*: uint32
        #Proof.
        proof*: uint32
        #Signature.
        signature*: BLSSignature

        #Block hash.
        hash*: ArgonHash

#Constructors.
func newBlockHeaderObj*(
    version: uint32,
    last: ArgonHash,
    contents: Hash[384],
    significant: uint16,
    sketchSalt: string,
    sketchCheck: Hash[384],
    miner: BLSPublicKey,
    time: uint32,
    proof: uint32,
    signature: BLSSignature
): BlockHeader {.forceCheck: [].} =
    result = BlockHeader(
        version: version,
        last: last,
        contents: contents,

        significant: significant,
        sketchSalt: sketchSalt,
        sketchCheck: sketchCheck,

        newMiner: true,
        minerKey: miner,
        time: time,
        proof: proof,
        signature: signature
    )
    result.ffinalizeVersion()
    result.ffinalizeLast()
    result.ffinalizeMinerKey()

func newBlockHeaderObj*(
    version: uint32,
    last: ArgonHash,
    contents: Hash[384],
    significant: uint16,
    sketchSalt: string,
    sketchCheck: Hash[384],
    miner: uint16,
    time: uint32,
    proof: uint32,
    signature: BLSSignature
): BlockHeader {.forceCheck: [].} =
    result = BlockHeader(
        version: version,
        last: last,
        contents: contents,

        significant: significant,
        sketchSalt: sketchSalt,
        sketchCheck: sketchCheck,

        newMiner: false,
        minerNick: miner,
        time: time,
        proof: proof,
        signature: signature
    )
    result.ffinalizeVersion()
    result.ffinalizeLast()
    result.ffinalizeMinerNick()

#Sign and hash the header via a passed in serialization.
proc hash*(
    miner: MinerWallet,
    header: var BlockHeader,
    serialized: string,
    proof: uint32
) {.forceCheck: [].} =
    header.proof = proof
    header.hash = Argon(
        serialized,
        header.proof.toBinary(SALT_LEN)
    )
    header.signature = miner.sign(header.hash.toString())
    header.hash = Argon(header.hash.toString(), header.signature.serialize())

#Hash the header via a passed in serialization.
proc hash*(
    header: var BlockHeader,
    serialized: string
) {.forceCheck: [].} =
    header.hash = Argon(
        Argon(
            serialized,
            header.proof.toBinary(SALT_LEN)
        ).toString(),
        header.signature.serialize()
    )
