import common from '@ohos.app.ability.common';
import { PetController } from '../controller/PetController';
import { Pet } from '../model/PetModel';
import StatusBar from '../components/StatusBar';

/**
 * 宠物主页面组件
 * 负责UI布局和用户交互，关联控制器层处理业务逻辑
 */
@Entry
@Component
struct Index {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  private petController: PetController = new PetController(this.context);

  @State private pet: Pet | null = null;
  @State private petEmoji: string = "🐱";
  @State private petStatusText: string = "开心";

  async aboutToAppear(): Promise<void> {
    await this.petController.Init();
    this.pet = JSON.parse(JSON.stringify(this.petController.GetPet())) as Pet;
    setInterval(() => {
      this.pet = JSON.parse(JSON.stringify(this.petController.GetPet())) as Pet;
    }, 30000);
  }

  aboutToDisappear(): void {
    this.petController.Destroy();
  }

  private updatePetFeedback(emoji: string, status: string): void {
    this.petEmoji = emoji;
    this.petStatusText = status;
    setTimeout(() => {
      this.petEmoji = "🐱";
      this.petStatusText = "开心";
    }, 2000);
  }

  private async onFeedClick(): Promise<void> {
    if (!this.pet) return;
    await this.petController.OnFeed();
    this.updatePetFeedback("😋", "干饭中~");
    this.pet = JSON.parse(JSON.stringify(this.petController.GetPet())) as Pet;
  }

  private async onGiveMedicineClick(): Promise<void> {
    if (!this.pet) return;
    await this.petController.OnGiveMedicine();
    this.updatePetFeedback("💊", "吃药药~");
    this.pet = JSON.parse(JSON.stringify(this.petController.GetPet())) as Pet;
  }

  private async onPlayClick(): Promise<void> {
    if (!this.pet) return;
    await this.petController.OnPlay();
    this.updatePetFeedback("🎮", "玩耍中~");
    this.pet = JSON.parse(JSON.stringify(this.petController.GetPet())) as Pet;
  }

  private async onDrinkClick(): Promise<void> {
    if (!this.pet) return;
    await this.petController.OnDrink();
    this.updatePetFeedback("💧", "喝水水~");
    this.pet = JSON.parse(JSON.stringify(this.petController.GetPet())) as Pet;
  }

  build() {
    Column() {
      // 顶部栏：状态条 + 陪伴天数
      Row() {
        Column({ space: 6 }) {
          StatusBar({ label: "健康", value: this.pet?.health ?? 100, color: "#4CAF50" })
          StatusBar({ label: "心情", value: this.pet?.mood ?? 100, color: "#FFC107" })
          StatusBar({ label: "饥饿", value: this.pet?.hunger ?? 100, color: "#FF9800" })
          StatusBar({ label: "口渴", value: this.pet?.thirst ?? 100, color: "#2196F3" })
        }
        .width("70%")
        .padding({ left: 10 })

        // 右侧陪伴天数
        Column() {
          Text(`陪伴: ${this.pet?.companionDays ?? 1}天`)
            .fontSize(20)
            .fontColor("#FFFFFF")
            .fontWeight(FontWeight.Bold)
            .margin({ right: 10 })
        }
        .width("30%")
        .height("100%")
        .alignItems(HorizontalAlign.End)
        .justifyContent(FlexAlign.Center)
      }
      .width("100%")
      .height("20%")
      .alignItems(VerticalAlign.Center)

      // 中间宠物展示区
      Stack({ alignContent: Alignment.Center }) {
        Column() {
          Text(this.petEmoji)
            .fontSize(80)
            .margin({ bottom: 15 });
          Text(this.petStatusText)
            .fontSize(18)
            .fontColor("#FFFFFF")
        }
        .width(200)
        .height(200)
        .border({ width: 2, color: "#FFFFFF", radius: 0 })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .width("100%")
      .height("55%")
      .margin({ top: 10 })

      // 底部按钮栏
      Row({ space: 20 }) {
        Button("喂食")
          .width(80)
          .height(45)
          .backgroundColor("#333333")
          .fontColor("#FFFFFF")
          .borderRadius(8)
          .onClick(() => this.onFeedClick())

        Button("喂药")
          .width(80)
          .height(45)
          .backgroundColor("#333333")
          .fontColor("#FFFFFF")
          .borderRadius(8)
          .onClick(() => this.onGiveMedicineClick())

        Button("玩耍")
          .width(80)
          .height(45)
          .backgroundColor("#333333")
          .fontColor("#FFFFFF")
          .borderRadius(8)
          .onClick(() => this.onPlayClick())

        Button("喂水")
          .width(80)
          .height(45)
          .backgroundColor("#333333")
          .fontColor("#FFFFFF")
          .borderRadius(8)
          .onClick(() => this.onDrinkClick())
      }
      .width("100%")
      .height("25%")
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .width("100%")
    .height("100%")
    .backgroundColor("#1a1a1a")
    .padding(10)
  }
}