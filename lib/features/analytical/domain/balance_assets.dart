/// Themed object packs used by Balance Logic. One pack per puzzle.
enum BalanceObjectSet { animals, foods }

/// Asset catalogs for Balance Logic weight objects.
abstract final class BalanceAssets {
  static const String animalsPrefix = 'assets/images/animals/';
  static const String foodsPrefix = 'assets/images/foods/';

  static const List<String> animals = [
    'assets/images/animals/bear.png',
    'assets/images/animals/buffalo.png',
    'assets/images/animals/chick.png',
    'assets/images/animals/chicken.png',
    'assets/images/animals/cow.png',
    'assets/images/animals/crocodile.png',
    'assets/images/animals/dog.png',
    'assets/images/animals/duck.png',
    'assets/images/animals/elephant.png',
    'assets/images/animals/frog.png',
    'assets/images/animals/giraffe.png',
    'assets/images/animals/goat.png',
    'assets/images/animals/gorilla.png',
    'assets/images/animals/hippo.png',
    'assets/images/animals/horse.png',
    'assets/images/animals/monkey.png',
    'assets/images/animals/moose.png',
    'assets/images/animals/narwhal.png',
    'assets/images/animals/owl.png',
    'assets/images/animals/panda.png',
    'assets/images/animals/parrot.png',
    'assets/images/animals/penguin.png',
    'assets/images/animals/pig.png',
    'assets/images/animals/rabbit.png',
    'assets/images/animals/rhino.png',
    'assets/images/animals/sloth.png',
    'assets/images/animals/snake.png',
    'assets/images/animals/walrus.png',
    'assets/images/animals/whale.png',
    'assets/images/animals/zebra.png',
  ];

  static const List<String> foods = [
    'assets/images/foods/Apple_green.png',
    'assets/images/foods/Avacado.png',
    'assets/images/foods/Banana.png',
    'assets/images/foods/Blueberries.png',
    'assets/images/foods/Bowl_of_cereal.png',
    'assets/images/foods/Broccoli.png',
    'assets/images/foods/Burrito.png',
    'assets/images/foods/Cake_slice.png',
    'assets/images/foods/Candy.png',
    'assets/images/foods/Candy_cane.png',
    'assets/images/foods/Carrot.png',
    'assets/images/foods/Cheese.png',
    'assets/images/foods/Cheeseburger.png',
    'assets/images/foods/Cherry.png',
    'assets/images/foods/Chocolate.png',
    'assets/images/foods/Cinnamon_roll.png',
    'assets/images/foods/Coconut.png',
    'assets/images/foods/Cookie.png',
    'assets/images/foods/Corn.png',
    'assets/images/foods/Croissant.png',
    'assets/images/foods/Donut_pink.png',
    'assets/images/foods/Drumstick.png',
    'assets/images/foods/Fish.png',
    'assets/images/foods/Hotdog.png',
    'assets/images/foods/Ice_cream_cone.png',
    'assets/images/foods/Lemon.png',
    'assets/images/foods/Loaf_of_bread.png',
    'assets/images/foods/Mushroom.png',
    'assets/images/foods/Onion_purple.png',
    'assets/images/foods/Orange.png',
    'assets/images/foods/Pepper_green.png',
    'assets/images/foods/Pickle.png',
    'assets/images/foods/Pineapple.png',
    'assets/images/foods/Pizza_slice.png',
    'assets/images/foods/Raspberries.png',
    'assets/images/foods/Tomato.png',
    'assets/images/foods/Uncooked_meat.png',
    'assets/images/foods/Waterbottle.png',
    'assets/images/foods/Watermelon_slice.png',
  ];

  static List<String> poolFor(BalanceObjectSet set) {
    return switch (set) {
      BalanceObjectSet.animals => animals,
      BalanceObjectSet.foods => foods,
    };
  }

  static BalanceObjectSet? setForAsset(String assetPath) {
    if (assetPath.startsWith(animalsPrefix)) {
      return BalanceObjectSet.animals;
    }
    if (assetPath.startsWith(foodsPrefix)) {
      return BalanceObjectSet.foods;
    }
    return null;
  }
}
