/**
 * 状态条组件
 * 通用UI组件，用于显示宠物的各类状态值（健康、心情、饥饿、口渴）
 * 包含状态名称文本和进度条展示
 */
@Component
export default struct StatusBar {
  /** 状态标签名称（如：健康、心情） */
  @Prop label: string = '';
  /** 状态值（0-100） */
  @Prop value: number = 0;
  /** 进度条颜色（十六进制字符串） */
  @Prop color: string = '';

  /**
   * 组件构建方法
   * 渲染状态标签和进度条
   */
  build() {
    Column({ space: 4 }) {
      Text(`${this.label}: ${this.value}`)
        .fontSize(14)
        .fontColor('#FFFFFF')
        .alignSelf(ItemAlign.Start);

      Progress({
        value: this.value,
        total: 100
      })
        .width(150)
        .height(8)
        .color(this.color)
        .backgroundColor('#333333')
        .borderRadius(4);
    }
    .alignItems(HorizontalAlign.Start);
  }
}