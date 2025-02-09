import asyncio
import json
from websockets.asyncio.client import connect
from google.cloud import pubsub_v1 as pubsub


def load_envs():
    import os
    from dotenv import load_dotenv

    load_dotenv()
    return {
        "PROJECT_ID": os.getenv("PROJECT_ID"),
        "TOPIC_NAME": os.getenv("TOPIC_NAME"),
    }


async def verify_connection(websocket):
    message = {"op": "ping"}
    json_message = json.dumps(message)
    await websocket.send(json_message)
    try:
        greeting = await asyncio.wait_for(websocket.recv(), timeout=5)
        response = json.loads(greeting)
        if "op" not in response or response["op"] != "pong":
            raise Exception(
                f"Malformed message sent. Check the sent message is correct: {json_message}"
            )
            return
    except asyncio.TimeoutError as e:
        print(e)
        raise Exception("Timeout error. No answer from the server.")


async def subscribe_to_unconfirmed_transactions(websocket):
    message = {"op": "unconfirmed_sub"}
    json_message = json.dumps(message)
    await websocket.send(json_message)
    try:
        await asyncio.wait_for(websocket.recv(), timeout=5)
    except asyncio.TimeoutError:
        raise Exception(
            f"Timeout error. No answer from the server. Verify the message sent is correct: {json_message}"
        )


async def read_messages(websocket):
    while True:
        response = await websocket.recv(websocket)
        print(response)


async def push_message(message, project_id, topic_name):
    publisher = pubsub.PublisherClient()
    topic_path = publisher.topic_path(project_id, topic_name)
    message = message.encode("utf-8")
    future = publisher.publish(topic_path, data=message)
    return future.result()


async def generator():
    uri = "wss://ws.blockchain.info/inv"
    trx_time = 180
    envs = load_envs()
    print(envs["PROJECT_ID"], envs["TOPIC_NAME"])
    async with connect(uri) as websocket:
        # Validate connection and subscribe to unconfirmed transactions
        try:
            await verify_connection(websocket)
            await subscribe_to_unconfirmed_transactions(websocket)
        except Exception as e:
            print(f"Connection failed: {e}")
            return

        # Read messages for trx_time minutes
        try:
            await asyncio.wait_for(read_messages(websocket), timeout=trx_time)
        except asyncio.TimeoutError:
            print(
                f"-- Stopped after successfully receiving transactions for {trx_time} seconds. Timeout activated."
            )


if __name__ == "__main__":
    asyncio.run(generator())
