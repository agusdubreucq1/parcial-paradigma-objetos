/*
* Nombre: Dubreucq agustin
* Legajo: 178247-2
*/
class Imperio{
	var property dinero=0
	const property ciudades=[]
	
	method estaEndeudado()= dinero < 0
	
	method evolucionar(){
		self.ciudadesFelices().forEach({ciudad => ciudad.crecerPoblacion(2)})
		self.edificios().evolucionar()
	}
	
	method ciudadesFelices()=
		ciudades.filter({ciudad => ciudad.esFeliz()})
	
	method pagar(dineroAPagar){
		dinero-=dineroAPagar
	}
	
	method cobrar(dineroACobrar){
		dinero+=dineroACobrar
	}
	
	method edificios()=
		ciudades.map({ciudad => ciudad.edificios()}).flatten()
}

class Ciudad{
	var property imperio
	var property habitantes
	var property tanques
	var property sistemaImpositivo
	const property edificios=[]
	
	method esFeliz()=
		not imperio.estaEndeudado() && edificios.sum({edificio => edificio.tranquilidad()}) > self.disconformidad()
	
	method disconformidad()=
		habitantes / 10000 + 30.min(tanques)
	
	method construir(edificio){
		if(self.puedeConstruirse(edificio))
			throw new ConstruccionFallida(message="no se pudo construir el edificio")
		imperio.pagar(self.costoDeConstruccion(edificio))
		self.agregarEdificio(edificio)
	}
	
	method puedeConstruirse(edificio)=
		imperio.dinero() >= self.costoDeConstruccion(edificio)
	
	method agregarEdificio(edificio){
		edificios.add(edificio)
	}
	
	method costoDeConstruccion(edificio)=
		sistemaImpositivo.costo(edificio)
	
	method crecerPoblacion(porcentaje){
		habitantes *= (1+ porcentaje/100)
	}
	
	method agregarTanques(cant){
		tanques+=cant
	}
	
	method cobrarAlImperio(dinero){
		imperio.pagar(dinero)
	}
	
	method pagarAlImperio(dinero){
		imperio.cobrar(dinero)
	}
}

class Capital inherits Ciudad{
	
}

/*
 * Edificios-----------------------------------
 */
 class Edificio{
 	var property ciudad
 	var property costoDeConstruccionBase
 	method costoDeMantenimiento()=
 		self.costoDeConstruccion()*0.01
 	method ciudadFeliz()= ciudad.esFeliz()
 	method evolucionar(){
 		ciudad.cobrarAlImperio(self.costoDeMantenimiento())
 	}
 	
 	method costoDeConstruccion()=
 		ciudad.costoDeConstruccion(self)
 		
 }
 
 class EdificioEconomico inherits Edificio{
 	const property dineroAlEvolucionar
 	const property cultura =0
 	method tranquilidad() = 3
 	
 	override method evolucionar(){
 		super()
 		ciudad.pagarAlImperio(dineroAlEvolucionar)
 		
 	}
 }
 
 class EdificioCultural inherits Edificio{
 	const property cultura
 	method tranquilidad() = cultura * 3
 	method efectoAlEvolucionar(imperio){
 		
 	}
 }
 
 class EdificioMilitar inherits Edificio{
 	var property tanquesGenerados
 	const property cultura=0
 	const property tranquilidad =0
 	override method evolucionar(){
 		super()
 		ciudad.agregarTanques(tanquesGenerados)
 		
 	}
 	
 }
 
 /*
  * sistemas Impositivos
  */
  
  object citadino{
  	var property cadaCuantosHabitantes=1
  	
  	method costo(edificio)=edificio.costoDeConstruccionBase() * (1 + 0.05*edificio.habitantes().div(cadaCuantosHabitantes))
  }
  
  object incentivoCultural{
  	method costo(edificio)= edificio.costoDeConstruccionBase() - edificio.cultura() /3
  }
  
  object apaciguador{
  	method costo(edificio) {
  		if(edificio.ciudadFeliz()){
  			return edificio.costoDeConstruccionBase()
  		}
  		else{
  			return edificio.costoDeConstruccionBase() - edificio.tranquilidad()
  		}
  	}
  }
  
  /*
   * Excepciones
   */
   
   class ConstruccionFallida inherits Exception{}