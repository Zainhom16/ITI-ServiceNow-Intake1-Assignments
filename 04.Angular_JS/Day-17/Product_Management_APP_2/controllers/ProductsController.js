app.controller(
  "ProductsController",
  function ($scope, ProductService, $routeParams) {
    $scope.products = [];
    $scope.selectedProduct = {};
    $scope.newProduct = {
      name: "",
      price: null,
      brand: "",
    };

    $scope.loading = false;

    $scope.Init = function () {
      $scope.loading = true;
      ProductService.getProducts()
        .then(function (response) {
          $scope.products = response.data;
        })
        .catch(function (error) {
          console.error("Error fetching Products:", error);
        })
        .finally(function () {
          $scope.loading = false;
        });
    };

    $scope.Init();

    $scope.getProductById = function (id) {
      $scope.loading = true;
      ProductService.getProductById(id)
        .then(function (response) {
          $scope.selectedProduct = response.data[0];
        })
        .finally(function () {
          $scope.loading = false;
        });
    };

    if ($routeParams.id) {
      $scope.getProductById($routeParams.id);
    }

    $scope.addProduct = function () {
      $scope.loading = true;
      ProductService.addProduct($scope.newProduct).then(function (response) {
        $scope.Init();
        $scope.newProduct = { name: "", price: null, brand: "" };
        $scope.loading = false;
      });
    };

    $scope.deleteProduct = function (id) {
      $scope.loading = true;
      ProductService.deleteProduct(id).then(function () {
        $scope.Init();
        $scope.loading = false;
      });
    };

    $scope.editProduct = function (product) {
      product.isEditing = true;
      product.tempName = product.name;
    };

    $scope.cancelEdit = function (product) {
      product.isEditing = false;
    };

    $scope.saveEdit = function (product) {
      $scope.loading = true;

      const updatedData = {
        name: product.tempName,
        price: product.price,
        brand: product.brand,
      };

      ProductService.updateProduct(product.id, updatedData)
        .then(function () {
          product.name = product.tempName;
          product.isEditing = false;
        })
        .catch(function (error) {
          console.error("Update failed:", error);
        })
        .finally(function () {
          $scope.loading = false;
        });
    };
  },
);
