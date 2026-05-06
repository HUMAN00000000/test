import promptAction from '@ohos.promptAction';
import systemDateTime from '@ohos.systemDateTime';
import { Pet, DataManager } from '../model/PetModel';
import common from '@ohos.app.ability.common';

/**
 * 宠物控制器类
 * 作为视图层与数据层的中间层，处理核心业务逻辑
 * 包括状态更新、陪伴天数计算、按钮交互逻辑等
 */
export class PetController {
  private pet: Pet;
  private timerId: number = -1;
  private uiContext: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.pet = new Pet();
    this.uiContext = context;
  }

  async Init(): Promise<void> {
    try {
      this.pet = await DataManager.LoadPet(this.uiContext);
      await this.pet.InitTime();
      await this.CalculateCompanionDays();
      await this.UpdatePetStatus();
      this.StartScheduleTask();
    } catch (error) {
      console.error("控制器初始化失败", error);
    }
  }

  /**
   * 计算陪伴天数
   */
  private async CalculateCompanionDays(): Promise<void> {
    // 修复：API10 正确方法 getTime()
    const currentTime = await systemDateTime.getTime();
    const lastTime = this.pet.lastUpdateTime;

    if (lastTime > 0) {
      const currentDate = new Date(currentTime);
      const lastDate = new Date(lastTime);
      const isDifferentDay = currentDate.getDate() !== lastDate.getDate() ||
        currentDate.getMonth() !== lastDate.getMonth() ||
        currentDate.getFullYear() !== lastDate.getFullYear();

      if (isDifferentDay) {
        this.pet.companionDays += 1;
        await DataManager.SavePet(this.uiContext, this.pet);
      }
    }
  }

  private StartScheduleTask(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
    }
    this.timerId = setInterval(async () => {
      await this.UpdatePetStatus();
    }, 30000);
  }

  async OnFeed(): Promise<void> {
    this.pet.Feed();
    await DataManager.SavePet(this.uiContext, this.pet);
    this.CheckAndShowAlerts();
  }

  async OnGiveMedicine(): Promise<void> {
    this.pet.GiveMedicine();
    await DataManager.SavePet(this.uiContext, this.pet);
    this.CheckAndShowAlerts();
  }

  async OnPlay(): Promise<void> {
    this.pet.Play();
    await DataManager.SavePet(this.uiContext, this.pet);
    this.CheckAndShowAlerts();
  }

  async OnDrink(): Promise<void> {
    this.pet.Drink();
    await DataManager.SavePet(this.uiContext, this.pet);
    this.CheckAndShowAlerts();
  }

  async UpdatePetStatus(): Promise<void> {
    await this.pet.UpdateStatus();
    await this.CalculateCompanionDays();
    await DataManager.SavePet(this.uiContext, this.pet);
    this.CheckAndShowAlerts();
  }

  CheckAndShowAlerts(): void {
    const lowStatusList = this.pet.CheckLowStatus();
    if (lowStatusList.length === 0) return;

    lowStatusList.forEach(status => {
      promptAction.showDialog({
        title: "状态提醒",
        message: `你的宠物${status}太低了！`,
        buttons: [{ text: "知道了", color: "#000000" }]
      });
    });
  }

  GetPet(): Pet {
    return this.pet;
  }

  Destroy(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }
}