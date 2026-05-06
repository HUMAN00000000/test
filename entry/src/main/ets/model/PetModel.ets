import preferences from '@ohos.data.preferences';
import systemDateTime from '@ohos.systemDateTime';
import common from '@ohos.app.ability.common';

/**
 * 宠物数据模型类
 * 管理宠物的所有状态数据（健康、心情、饥饿、口渴）和陪伴天数
 * 提供状态修改方法，确保数值在0-100范围内
 */
export class Pet {
  /** 健康值（0-100） */
  health: number = 100;
  /** 心情值（0-100） */
  mood: number = 100;
  /** 饥饿值（饱食度，0-100） */
  hunger: number = 100;
  /** 口渴值（0-100） */
  thirst: number = 100;
  /** 陪伴天数（永久保存，跨天自动+1） */
  companionDays: number = 1;
  /** 最后一次更新状态的时间戳（用于跨天计算） */
  lastUpdateTime: number = 0;

  /**
   * 初始化最后更新时间戳
   * 用于后续跨天判断陪伴天数
   */
  async InitTime(): Promise<void> {
    this.lastUpdateTime = await systemDateTime.getTime();
  }

  /**
   * 数值约束方法
   * 确保传入的数值限制在0-100之间
   * @param value 待约束的数值
   * @returns 约束后的数值（0≤value≤100）
   */
  private ClampValue(value: number): number {
    return Math.max(0, Math.min(100, value));
  }

  /**
   * 喂食方法
   * 饥饿值+10，严格约束0-100范围
   */
  Feed(): void {
    this.hunger = this.ClampValue(this.hunger + 10);
  }

  /**
   * 喂药方法
   * 健康值+10，严格约束0-100范围
   */
  GiveMedicine(): void {
    this.health = this.ClampValue(this.health + 10);
  }

  /**
   * 玩耍方法
   * 心情值+10，严格约束0-100范围
   */
  Play(): void {
    this.mood = this.ClampValue(this.mood + 10);
  }

  /**
   * 喝水方法
   * 口渴值+10，严格约束0-100范围
   */
  Drink(): void {
    this.thirst = this.ClampValue(this.thirst + 10);
  }

  /**
   * 更新宠物状态（自动消耗）
   * 按分钟递减饥饿、口渴、心情值、健康值
   */
  async UpdateStatus(): Promise<void> {
    // 获取当前时间戳
    const currentTime = await systemDateTime.getTime();
    // 计算与上次更新的时间差（毫秒）
    const timeDiff = currentTime - this.lastUpdateTime;
    // 转换为分钟数
    const minutesDiff = Math.floor(timeDiff / (1000 * 60));

    // 仅当时间差大于0时更新状态
    if (minutesDiff > 0) {
      // 原有逻辑：基础状态自动消耗
      this.hunger = this.ClampValue(this.hunger - minutesDiff * 1);
      this.thirst = this.ClampValue(this.thirst - minutesDiff * 1);
      this.mood = this.ClampValue(this.mood - minutesDiff * 0.5);

      // 触发条件：饥饿/口渴/心情 任意一个 < 30
      const needReduceHealth = this.hunger < 30 || this.thirst < 30 || this.mood < 30;
      if (needReduceHealth) {
        // 下降规则：每分钟健康值 -2，最低为0
        this.health = this.ClampValue(this.health - minutesDiff * 2);
      }

      // 更新最后更新时间戳
      this.lastUpdateTime = currentTime;
    }
  }

  /**
   * 检查低状态值
   * 当健康/心情/饥饿/口渴值低于20时，返回对应的状态名称数组
   * @returns 低状态值名称数组
   */
  CheckLowStatus(): string[] {
    const lowStatusList: string[] = [];
    if (this.health < 20) lowStatusList.push('健康值');
    if (this.mood < 20) lowStatusList.push('心情值');
    if (this.hunger < 20) lowStatusList.push('饥饿值');
    if (this.thirst < 20) lowStatusList.push('口渴值');
    return lowStatusList;
  }
}

/**
 * 数据管理类
 * 负责宠物数据的本地持久化存储（Preferences）
 * 提供保存/加载宠物数据的静态方法
 */
export class DataManager {
  private static readonly STORE_NAME: string = 'PetDataStore';
  private static readonly PET_DATA_KEY: string = 'PetData';

  static async SavePet(context: common.UIAbilityContext, pet: Pet): Promise<void> {
    try {
      const store = await preferences.getPreferences(context, DataManager.STORE_NAME);
      await store.put(DataManager.PET_DATA_KEY, JSON.stringify(pet));
      await store.flush();
    } catch (error) {
      console.error('保存宠物数据失败:', error);
    }
  }

  static async LoadPet(context: common.UIAbilityContext): Promise<Pet> {
    try {
      const store = await preferences.getPreferences(context, DataManager.STORE_NAME);
      const petData = await store.get(DataManager.PET_DATA_KEY, '') as string;

      if (petData) {
        const parsedPet: Partial<Pet> = JSON.parse(petData);
        const pet = new Pet();
        pet.health = parsedPet.health ?? 100;
        pet.mood = parsedPet.mood ?? 100;
        pet.hunger = parsedPet.hunger ?? 100;
        pet.thirst = parsedPet.thirst ?? 100;
        pet.companionDays = parsedPet.companionDays ?? 1;
        pet.lastUpdateTime = parsedPet.lastUpdateTime ?? 0;
        return pet;
      }
    } catch (error) {
      console.error('加载宠物数据失败:', error);
    }
    const pet = new Pet();
    await pet.InitTime();
    return pet;
  }
}