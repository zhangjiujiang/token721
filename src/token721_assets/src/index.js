import { Actor, HttpAgent } from '@dfinity/agent';
import { idlFactory as token721_idl, canisterId as token721_id } from 'dfx-generated/token721';

const agent = new HttpAgent();
const token721 = Actor.createActor(token721_idl, { agent, canisterId: token721_id });

document.getElementById("clickMeBtn").addEventListener("click", async () => {
  const name = document.getElementById("name").value.toString();
  const greeting = await token721.greet(name);

  document.getElementById("greeting").innerText = greeting;
});
