#Errors lib.
import ../../../lib/Errors

#Hash lib.
import ../../../lib/Hash

#MinerWallet lib.
import ../../../Wallet/MinerWallet

#VerificationPacket lib.
import VerificationPacket as VerificationPacketFile

#MeritRemoval object.
import objects/MeritRemovalObj
export MeritRemovalObj

#Serialization libs.
import ../../../Network/Serialize/SerializeCommon
import ../../../Network/Serialize/Consensus/SerializeVerification
import ../../../Network/Serialize/Consensus/SerializeVerificationPacket
import ../../../Network/Serialize/Consensus/SerializeMeritRemoval

#Constructor wrappers.
func newMeritRemoval*(
    nick: uint16,
    partial: bool,
    e1Arg: Element,
    e2Arg: Element,
    lookup: seq[BLSPublicKey]
): MeritRemoval {.forceCheck: [].} =
    var
        e1: Element = e1Arg
        e2: Element = e2Arg
    if e1 of VerificationPacket:
        e1 = cast[VerificationPacket](e1).toMeritRemovalVerificationPacket(lookup)
    if e2 of VerificationPacket:
        e2 = cast[VerificationPacket](e2).toMeritRemovalVerificationPacket(lookup)

    result = newMeritRemovalObj(
        nick,
        partial,
        e1,
        e2
    )

func newSignedMeritRemoval*(
    nick: uint16,
    partial: bool,
    e1Arg: Element,
    e2Arg: Element,
    signature: BLSSignature,
    lookup: seq[BLSPublicKey]
): SignedMeritRemoval {.inline, forceCheck: [].} =
    var
        e1: Element = e1Arg
        e2: Element = e2Arg
    if e1 of VerificationPacket:
        e1 = cast[VerificationPacket](e1).toMeritRemovalVerificationPacket(lookup)
    if e2 of VerificationPacket:
        e2 = cast[VerificationPacket](e2).toMeritRemovalVerificationPacket(lookup)

    newSignedMeritRemovalObj(
        nick,
        partial,
        e1,
        e2,
        signature
    )

#Calculate the MeritRemoval's Merkle leaf hash.
proc merkle*(
    mr: MeritRemoval
): Hash[256] {.forceCheck: [].} =
    Blake256(char(MERIT_REMOVAL_PREFIX) & mr.serialize())

#Calculate the MeritRemoval's aggregation info.
proc agInfo*(
    mr: MeritRemoval,
    holder: BLSPublicKey
): BLSAggregationInfo {.forceCheck: [].} =
    try:
        if mr.element2 of MeritRemovalVerificationPacket:
            var packet: MeritRemovalVerificationPacket = cast[MeritRemovalVerificationPacket](mr.element2)
            result = newBLSAggregationInfo(packet.holders.aggregate(), packet.serializeAsVerificationWithoutHolder())
        else:
            result = newBLSAggregationInfo(holder, mr.element2.serializeWithoutHolder())

        #If this is a partial MeritRemoval, the signature is just the second Element's.
        if mr.partial:
            return

        if mr.element1 of MeritRemovalVerificationPacket:
            var packet: MeritRemovalVerificationPacket = cast[MeritRemovalVerificationPacket](mr.element1)
            result = @[
                newBLSAggregationInfo(packet.holders.aggregate(), packet.serializeAsVerificationWithoutHolder()),
                result
            ].aggregate()
        else:
            result = @[
                newBLSAggregationInfo(holder, mr.element1.serializeWithoutHolder()),
                result
            ].aggregate()
    except BLSError:
        panic("Holder with an infinite key entered the system.")
