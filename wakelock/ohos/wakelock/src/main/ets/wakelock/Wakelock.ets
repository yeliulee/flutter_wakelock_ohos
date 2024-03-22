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

import { Log, Any } from '@ohos/flutter_ohos';
import { IsEnabledMessage, ToggleMessage } from './Messages';
import common from '@ohos.app.ability.common';
import window from '@ohos.window';

const TAG = "Wakelock.ohos";

export interface WakelockApi {
  toggle(msg: ToggleMessage): Promise<void>;

  isEnabled(): IsEnabledMessage;
}

export class Wakelock implements WakelockApi {
  private enabled: boolean = false;
  context?: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  toggle(message: ToggleMessage): Promise<void> {
    if (!this.context) {
      throw new NoAbilityError();
    }
    return new Promise<void>((resolve, reject) => {
      window.getLastWindow(this.context).then((data) => {
        return Promise.resolve(data);
      }).then((windowClass: window.Window) => {
        let isKeepScreenOn: boolean = message.enable as boolean;
        Log.i(TAG, "message=" + message.enable);
        Log.i(TAG, "this.enabled=" + this.enabled);
        Log.i(TAG, "isKeepScreenOn=" + isKeepScreenOn);
        windowClass.setWindowKeepScreenOn(isKeepScreenOn).then(() => {
          Log.i(TAG, "setWindowKeepScreenOn success");
          this.enabled = isKeepScreenOn;
          resolve();
        }).catch((err: Any) => {
          this.enabled = false;
          reject(err);
          Log.e(TAG, "setWindowKeepScreenOn error: " + JSON.stringify(err));
        })
      }).catch((err: Any) => {
        this.enabled = false;
        reject(err);
        Log.i(TAG, "setWindowKeepScreenOn other error: " + JSON.stringify(err));
      })
    })
  }

  isEnabled(): IsEnabledMessage {
    if (this.context == null) {
      throw new NoAbilityError()
    }
    let msg = new IsEnabledMessage();
    msg.enabled = this.enabled;
    return msg;
  }
}

export class NoAbilityError extends Error {
  constructor() {
    super("wakelock requires a foreground Ability.")
  }
}