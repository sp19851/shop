const App = {
  data() {
    return {
      show: false,
      dialogShow: false,
      dialogValue: 1,
      label: "Магазин",
      currentItem_info_img: "",
      currentItem_info_text: "",
      currentItem_info_imgShow: false,
      currentItem: "",
      currentPage: "cat",
      backBtnLabel: "Выход",

      /*items: [
                {"id":1, "value":"food","label":"Пища", "info":{"img":"./img/shop/category/food.png", "text":"Продукты питания и напитки"}, "event":"", "args":""},
                {"id":2, "value":"medic","label":"Медикаменты", "info":{"img":"./img/shop/category/medic.png", "text":"Берегите здоровье смолоду"}, "event":"", "args":""},
                {"id":3, "value":"tools","label":"Инструменты",  "info":{"img":"./img/shop/category/tools.png", "text":"С ними будет полегче"}, "event":"", "args":""},

            ],
            startitems: [
                {"id":1, "value":"food","label":"Пища", "info":{"img":"./img/shop/category/food.png", "text":"Продукты питания и напитки"}, "event":"", "args":""},
                {"id":2, "value":"medic","label":"Медикаменты", "info":{"img":"./img/shop/category/medic.png", "text":"Берегите здоровье смолоду"}, "event":"", "args":""},
                {"id":3, "value":"tools","label":"Инструменты",  "info":{"img":"./img/shop/category/tools.png", "text":"С ними будет полегче"}, "event":"", "args":""},

            ],
            subitems: [
                {"id":1, "value":"apple","label":"Яблоко", "info":{"img":"./img/shop/items/apple.png", "text":"Стоимость $0.1"}, "event":"", "args":""},
                {"id":2, "value":"apple","label":"Плитка шоколада", "info":{"img":"./img/shop/items/consumable_chocolate.png", "text":"Стоимость $1.0"}, "event":"", "args":""}
                
            ],*/
      cat: [],
      itemsList: [],
    };
  },

  components: {},
  methods: {
    showingForm() {
      //console.log('showingForm')
      this.show = true;
    },
    onClose() {
      this.show = false;
      this.currentPage = "cat";
      this.dialogShow = false;
      $.post("https://shop/close");
    },
    load_in_info(item) {
      //загрузка данные в переменные инфо для отображния в футоре при наведении на итем
      //console.log(JSON.stringify(item))
      this.currentItem_info_img = item.info.img;
      this.currentItem_info_text = item.info.text;
      this.currentItem_info_imgShow = true;
    },
    imgUrl(element) {
      //console.log('41element', element)

      return `${element}`;
    },
    onBack() {
      //загрузка данных в переменные инфо для отображния в футоре при наведении на назад

      this.currentItem_info_imgShow = false;
    },
    selectItem(item) {
      //запуск функции из item
      //console.log('seleced item', JSON.stringify(item))
      //console.log('this.itemsList', JSON.stringify(item))
      if (this.currentPage === "cat") {
        let ar = [...this.itemsList].filter((cat) => cat.id_cat == item.id_cat);
        this.items = ar;
        this.currentPage = "items";
        /*this.items = this.itemsList.filter((cat) => {
                    console.log('67 item.id', item.id_cat, JSON.stringify(cat))
                    cat.id_cat==item.id_cat
                })*/
        this.backBtnLabel = "Назад";
        //console.log('subitems', JSON.stringify(this.items))
      } else if (this.currentPage === "items") {
        this.currentItem = item;
        this.dialogShow = true;
        //POST
      }
    },
    inputVal(e) {
      console.log('inputVal', e.target.value)
      //this.dialogValue = e.target.value;
    },
    accept() {
      //POST
      //$pos
      
      if (this.label == "Магазин") {
        $.post(
          "https://shop/buy",
          JSON.stringify({
            item: this.currentItem.value,
            value: this.dialogValue,
            money: this.currentItem.price * this.dialogValue,
            type: 1,
          })
        );
      } else {
        $.post(
          "https://shop/buy",
          JSON.stringify({
            item: this.currentItem.value,
            value: this.dialogValue,
            money: this.currentItem.price * this.dialogValue,
            type: 0,
          })
        );
      }
      this.dialogShow = false;
      this.dialogValue = 1;
    },

    closeDialog() {
      this.dialogShow = false;
    },
    selectBack() {
      //запуск функции из item
      if (this.backBtnLabel == "Выход") {
        this.onClose();
      } else {
        this.items = this.cat;
        this.currentPage = "cat";

        this.backBtnLabel = "Выход";
        //POST
      }
    },
  },

  mounted() {
    this.listener = window.addEventListener("message", (event) => {
      //console.log('test window.addEventListener', event.data.action)
      //console.log('93itemsList', JSON.stringify(event.data))
      if (event.data.action === "open") {
        this.cat = event.data.cat;
        this.itemsList = event.data.items;
        this.items = this.cat;
        this.backBtnLabel = "Выход";
        if (event.data.type === "1") {
          this.label = "Магазин";
        } else {
          this.label = "Скупщик";
        }
        this.showingForm(true);
      } else if (event.data.action === "close") {
        this.onClose();
      }
    });
    window.document.onkeydown = (event) =>
      event && event.code === "Escape" ? this.onClose() : null;
    let data = {
      id: this.notifyCounter,
      message:
        "Lorem ipsum, dolor sit amet consect fdgdsfghdfghdfhsdfhdshsdfhsdelit. ",
      type: "success",
    };
    /* let img = '../img/'+data.type+'.png'
       // console.log('img', img, data.type)
        let newEl = {
            id: this.notifyCounter,
            message: data.message,
            type: data.type,
            image: img,
            time: data.time,
            

        }
        
       
        setInterval(
            
            () => {
              this.newNotify(data)
            },
            5 * 1000
        );*/
  },
  create: {},
  watch: {},

  computed: {},
};

let app = Vue.createApp(App);
app.mount("#app");
