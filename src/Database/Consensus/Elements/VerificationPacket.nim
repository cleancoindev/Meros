#Errors lib.
import ../../../lib/Errors

#MinerWallet lib.
import ../../../Wallet/MinerWallet

#Verification lib.
import Verification

#VerificationPacket object.
import objects/VerificationPacketObj
export VerificationPacketObj

#Add a Verification to a VerificationPacket.
proc add*(
    packet: VerificationPacket,
    verif: Verification
) {.forceCheck: [].} =
    packet.holders.add(verif.holder)

#Add a SignedVerification to a SignedVerificationPacket.
proc add*(
    packet: SignedVerificationPacket,
    verif: SignedVerification
) {.forceCheck: [].} =
    packet.holders.add(verif.holder)
    packet.signatures.add(verif.signature)
    if packet.signatures.len == 1:
        packet.signature = packet.signatures[0]
    else:
        try:
            packet.signature = @[
                packet.signature,
                verif.signature
            ].aggregate()
        except BLSError as e:
            doAssert(false, "Couldn't add a new SignedVerification to an existing packet: " & e.msg)

#Error if the add function is called when one arg is signed but the other is not.
proc add*(
    packet: VerificationPacket,
    verif: SignedVerification
) {.error: "Adding a SignedVerification to a VerificationPacket".}

proc add*(
    packet: SignedVerificationPacket,
    verif: Verification
) {.error: "Adding a Verification to a SignedVerificationPacket".}
