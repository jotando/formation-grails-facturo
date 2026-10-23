package facturo

class ProduitController {

    def index() {
        [produits: Produit.list()]
    }
}
