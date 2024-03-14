/*
* Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
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

import AbilityAware from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityAware';
import { AbilityPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityPluginBinding';
import {
  FlutterPlugin,
  FlutterPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import { Messages } from './Messages';
import { Wakelock } from './Wakelock';

const TAG = "WakelockPlugin"

export class WakelockPlugin implements FlutterPlugin, AbilityAware {
  private pluginBinding : FlutterPluginBinding | null = null;
  private wakelock : Wakelock | null = null;

  getUniqueClassName(): string {
    return "WakelockPlugin"
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.wakelock = new Wakelock(binding.getAbility().context);
    if (this.pluginBinding != null) {
      Messages.setup(this.pluginBinding.getBinaryMessenger(), this.wakelock);
    }
  }

  onDetachedFromAbility(): void {
    this.wakelock = null;
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.pluginBinding = binding;
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.pluginBinding = null;
  }
}