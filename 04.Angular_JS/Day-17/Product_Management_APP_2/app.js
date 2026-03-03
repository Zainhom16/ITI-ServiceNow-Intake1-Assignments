var app = angular.module("MyApp", ["ngRoute"]);

app.config(function ($routeProvider) {
  $routeProvider
    .when("/products", {
      templateUrl: "views/products.html",
      controller: "ProductsController",
    })
    .otherwise({
      redirectTo: "/products",
    });
});
