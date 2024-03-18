/*
* Copyright (c) 2024 Hunan OpenValley Digital Industry Development Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import { BasicMessageChannel, BinaryMessenger, ByteBuffer, Log, MessageCodec } from '@ohos/flutter_ohos';
import { Reply } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BasicMessageChannel';
import StandardMessageCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/StandardMessageCodec';
import ArrayList from '@ohos.util.ArrayList';
import { WakelockApi } from './Wakelock';

const TAG = "wakelock.Messages";

export class ToggleMessage {
  enable: Boolean = false;

  toMap(): Map<String, ESObject> {
    let toMapResult: Map<String, ESObject> = new Map<String, ESObject>();
    toMapResult.set("enable", this.enable);
    return toMapResult;
  }

  static fromMap(map: Map<String, ESObject>): ToggleMessage {
    let fromMapResult = new ToggleMessage();
    let enable: Boolean = map.get("enable") ?? false;
    fromMapResult.enable = enable;
    return fromMapResult;
  }
}

export class IsEnabledMessage {
  enabled: Boolean = false;

  toMap(): Map<String, ESObject> {
    let toMapResult: Map<String, ESObject> = new Map<String, ESObject>();
    toMapResult.set("enabled", this.enabled);
    return toMapResult;
  }

  static fromMap(map: Map<String, ESObject>): IsEnabledMessage {
    let fromMapResult = new IsEnabledMessage();
    let enabled: Boolean = map.get("enabled") ?? false;
    fromMapResult.enabled = enabled;
    return fromMapResult;
  }
}

class WakelockApiCodec extends StandardMessageCodec {
  static INSTANCE: WakelockApiCodec = new WakelockApiCodec();

  private constructor() {
    super();
  }

  readValueOfType(type: number, buffer: ByteBuffer): ESObject {
    // Log.i(TAG, "readValueOfType type=" + type + ", buffer=" + buffer);
    switch (type) {
      case 128:
        return IsEnabledMessage.fromMap(this.readValue(buffer) as Map<String, ESObject>);

      case 129:
        return ToggleMessage.fromMap(this.readValue(buffer) as Map<String, ESObject>);

      default:
        return super.readValueOfType(type, buffer);
    }
  }

  writeValue(stream: ByteBuffer, value: ESObject): ESObject {
    if (value instanceof IsEnabledMessage) {
      stream.writeUint8(128);
      this.writeValue(stream, value.toMap());
    } else if (value instanceof ToggleMessage) {
      stream.writeUint8(129);
      this.writeValue(stream, value.toMap());
    } else {
      super.writeValue(stream, value);
    }
  }
}

export class Messages {
  static getCodec(): MessageCodec<ESObject> {
    return WakelockApiCodec.INSTANCE;
  }

  static setup(binaryMessenger: BinaryMessenger, api: WakelockApi): void {
    {
      const channel: BasicMessageChannel<ESObject> = new BasicMessageChannel<ESObject>(
        binaryMessenger, "dev.flutter.pigeon.WakelockApi.toggle", Messages.getCodec());
      if (api != null) {
        channel.setMessageHandler({
          onMessage(message: ESObject, reply: Reply<ESObject>): void {
            // Log.d(TAG, 'onMessage reply:' + reply)
            let wrapped: Map<String, ESObject> = new Map<String, ESObject>();
            try {
              let args: ArrayList<ESObject> = message as ArrayList<ESObject>;
              let msgArg: ToggleMessage = args[0] as ToggleMessage;

              Log.i(TAG, "received msgArg=" + JSON.stringify(msgArg));
              if (msgArg == null) {
                throw new Error("msgArg unexpectedly null.");
              }
              api.toggle(msgArg).then(()=> {
                Log.i(TAG, "toggle success");
                wrapped.set("result", null);
                reply.reply(wrapped);
              }).catch((err: ESObject) => {
                Log.i(TAG, "toggle failed: " + JSON.stringify(err));
                wrapped.set("error", Messages.wrapError(err));
                reply.reply(wrapped);
              });
            } catch (err) {
              Log.i(TAG, "toggle catch err: " + JSON.stringify(err));
              wrapped.set("error", Messages.wrapError(err));
              reply.reply(wrapped);
            }
          }
        });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      const channel: BasicMessageChannel<ESObject> = new BasicMessageChannel<ESObject>(
        binaryMessenger, "dev.flutter.pigeon.WakelockApi.isEnabled", Messages.getCodec());
      if (api != null) {
        channel.setMessageHandler({
          onMessage(message: ESObject, reply: Reply<ESObject>): void {
            // Log.d(TAG, 'onMessage reply:' + reply)
            let wrapped: Map<String, ESObject> = new Map<String, ESObject>();
            try {
              let output: IsEnabledMessage = api.isEnabled();
              wrapped.set("result", output);
            } catch (err) {
              wrapped.set("error", Messages.wrapError(err))
            }
            reply.reply(wrapped)
          }
        });
      } else {
        channel.setMessageHandler(null);
      }
    }
  }

  static wrapError(error: Error): Map<String, ESObject> {
    let errorMap: Map<String, ESObject> = new Map();
    errorMap.set("message", error.message);
    errorMap.set("code", error.name);
    errorMap.set("details", null);
    return errorMap;
  }
}