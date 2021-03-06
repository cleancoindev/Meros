#Tests proper handling of a MeritRemoval where one Element is already archived.

#Types.
from typing import Dict, IO, Any

#PartialMeritRemoval class.
from e2e.Classes.Consensus.MeritRemoval import PartialMeritRemoval

#TestError Exception.
from e2e.Tests.Errors import TestError

#Meros classes.
from e2e.Meros.Meros import MessageType
from e2e.Meros.RPC import RPC
from e2e.Meros.Liver import Liver
from e2e.Meros.Syncer import Syncer

#MeritRemoval verifier.
from e2e.Tests.Consensus.Verify import verifyMeritRemoval

#JSON standard lib.
import json

def PartialTest(
  rpc: RPC
) -> None:
  file: IO[Any] = open("e2e/Vectors/Consensus/MeritRemoval/Partial.json", "r")
  vectors: Dict[str, Any] = json.loads(file.read())
  file.close()

  #MeritRemoval.
  #pylint: disable=no-member
  removal: PartialMeritRemoval = PartialMeritRemoval.fromSignedJSON(vectors["removal"])

  #Create and execute a Liver to cause a Partial MeritRemoval.
  def sendElement() -> None:
    #Send the second Element.
    rpc.meros.signedElement(removal.se2)

    #Verify the MeritRemoval.
    if rpc.meros.live.recv() != (
      MessageType.SignedMeritRemoval.toByte() +
      removal.signedSerialize()
    ):
      raise TestError("Meros didn't send us the Merit Removal.")
    verifyMeritRemoval(rpc, 2, 2, removal.holder, True)

  Liver(
    rpc,
    vectors["blockchain"],
    callbacks={
      2: sendElement,
      3: lambda: verifyMeritRemoval(rpc, 2, 2, removal.holder, False)
    }
  ).live()

  #Create and execute a Liver to handle a Partial MeritRemoval.
  def sendMeritRemoval() -> None:
    #Send and verify the MeritRemoval.
    if rpc.meros.signedElement(removal) != rpc.meros.live.recv():
      raise TestError("Meros didn't send us the Merit Removal.")
    verifyMeritRemoval(rpc, 2, 2, removal.holder, True)

  Liver(
    rpc,
    vectors["blockchain"],
    callbacks={
      2: sendMeritRemoval,
      3: lambda: verifyMeritRemoval(rpc, 2, 2, removal.holder, False)
    }
  ).live()

  #Create and execute a Syncer to handle a Partial MeritRemoval.
  Syncer(rpc, vectors["blockchain"]).sync()
  verifyMeritRemoval(rpc, 2, 2, removal.holder, False)
