/// Themed object packs used by Balance Logic. One pack per puzzle.
enum BalanceObjectSet { animals, foods }

/// Asset catalogs for Balance Logic weight objects.
abstract final class BalanceAssets {
  static const String animalsPrefix = 'assets/balance/animals/';
  static const String foodsPrefix = 'assets/balance/foods/';

  static const List<String> animals = [
    'assets/balance/animals/bear.png',
    'assets/balance/animals/buffalo.png',
    'assets/balance/animals/chick.png',
    'assets/balance/animals/chicken.png',
    'assets/balance/animals/cow.png',
    'assets/balance/animals/crocodile.png',
    'assets/balance/animals/dog.png',
    'assets/balance/animals/duck.png',
    'assets/balance/animals/elephant.png',
    'assets/balance/animals/frog.png',
    'assets/balance/animals/giraffe.png',
    'assets/balance/animals/goat.png',
    'assets/balance/animals/gorilla.png',
    'assets/balance/animals/hippo.png',
    'assets/balance/animals/horse.png',
    'assets/balance/animals/monkey.png',
    'assets/balance/animals/moose.png',
    'assets/balance/animals/narwhal.png',
    'assets/balance/animals/owl.png',
    'assets/balance/animals/panda.png',
    'assets/balance/animals/parrot.png',
    'assets/balance/animals/penguin.png',
    'assets/balance/animals/pig.png',
    'assets/balance/animals/rabbit.png',
    'assets/balance/animals/rhino.png',
    'assets/balance/animals/sloth.png',
    'assets/balance/animals/snake.png',
    'assets/balance/animals/walrus.png',
    'assets/balance/animals/whale.png',
    'assets/balance/animals/zebra.png',
  ];

  static const List<String> foods = [
    'assets/balance/foods/Apple_green.png',
    'assets/balance/foods/Avacado.png',
    'assets/balance/foods/Banana.png',
    'assets/balance/foods/Blueberries.png',
    'assets/balance/foods/Bowl_of_cereal.png',
    'assets/balance/foods/Broccoli.png',
    'assets/balance/foods/Burrito.png',
    'assets/balance/foods/Cake_slice.png',
    'assets/balance/foods/Candy.png',
    'assets/balance/foods/Candy_cane.png',
    'assets/balance/foods/Carrot.png',
    'assets/balance/foods/Cheese.png',
    'assets/balance/foods/Cheeseburger.png',
    'assets/balance/foods/Cherry.png',
    'assets/balance/foods/Chocolate.png',
    'assets/balance/foods/Cinnamon_roll.png',
    'assets/balance/foods/Coconut.png',
    'assets/balance/foods/Cookie.png',
    'assets/balance/foods/Corn.png',
    'assets/balance/foods/Croissant.png',
    'assets/balance/foods/Donut_pink.png',
    'assets/balance/foods/Drumstick.png',
    'assets/balance/foods/Fish.png',
    'assets/balance/foods/Hotdog.png',
    'assets/balance/foods/Ice_cream_cone.png',
    'assets/balance/foods/Lemon.png',
    'assets/balance/foods/Loaf_of_bread.png',
    'assets/balance/foods/Mushroom.png',
    'assets/balance/foods/Onion_purple.png',
    'assets/balance/foods/Orange.png',
    'assets/balance/foods/Pepper_green.png',
    'assets/balance/foods/Pickle.png',
    'assets/balance/foods/Pineapple.png',
    'assets/balance/foods/Pizza_slice.png',
    'assets/balance/foods/Raspberries.png',
    'assets/balance/foods/Strawberries.png',
    'assets/balance/foods/Tomato.png',
    'assets/balance/foods/Uncooked_meat.png',
    'assets/balance/foods/Waterbottle.png',
    'assets/balance/foods/Watermelon_slice.png',
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
