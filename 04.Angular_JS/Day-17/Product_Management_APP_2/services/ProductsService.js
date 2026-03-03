app.service("ProductService", function ($http) {
  const SUPABASE_URL =
    "https://chngxvrspxusynptfqfa.supabase.co/rest/v1/products";
  const SUPABASE_KEY = "sb_publishable_ti5vwFIF2zAgEWKY3rBFlw_TrTqwtC4";
  const headers = {
    apikey: SUPABASE_KEY,
    Authorization: `Bearer ${SUPABASE_KEY}`,
    "Content-Type": "application/json",
  };

  this.getProducts = function () {
    return $http.get(SUPABASE_URL, { headers: headers });
  };

  this.getProductById = function (id) {
    return $http.get(`${SUPABASE_URL}?id=eq.${id}`, { headers: headers });
  };

  this.addProduct = function (product) {
    return $http.post(SUPABASE_URL, product, { headers: headers });
  };

  this.deleteProduct = function (id) {
    return $http.delete(`${SUPABASE_URL}?id=eq.${id}`, { headers: headers });
  };

  this.updateProduct = function (id, product) {
    return $http.patch(`${SUPABASE_URL}?id=eq.${id}`, product, {
      headers: headers,
    });
  };
});
