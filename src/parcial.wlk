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
		ciudades.forEach({ciudad => ciudad.evolucionar()})
	}
	
	method ciudadesFelices()=
		ciudades.filter({ciudad => ciudad.esFeliz()})
	
	method pagar(dineroAPagar){
		dinero-=dineroAPagar
	}
	
	method cobrar(dineroACobrar){
		dinero+=dineroACobrar
	}
	
	method tresCiudadesFelicesMenorCultura()=
		self.ciudadesFelices().sortedBy({x,y => x.cultura() < y.cultura()}).take(3)
	
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
		not imperio.estaEndeudado() &&  self.tranquilidad() > self.disconformidad()
	
	method disconformidad()=
		habitantes / 10000 + 30.min(tanques)
		
	method tranquilidad()=
		edificios.sum({edificio => edificio.tranquilidad()})
	
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
		edificio.costoDeConstruccionBase() + sistemaImpositivo.agregado(edificio)
	
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
	
	method cultura()=
		edificios.sum({edificio => edificio.cultura()})
	
	method pepinesGenerados()=
		edificios.sum({edificio => edificio.pepinesGenerados()})
	
	method evolucionar(){
		edificios.forEach({edificio => edificio.evolucionar()})
		imperio.cobrar(self.pepinesGenerados())
	}
	
}

class Capital inherits Ciudad{
	override method disconformidad()=
		super().div(2)
		
	override method costoDeConstruccion(edificio)=
		super(edificio) * 1.1
		
	override method evolucionar(){
		super()
		if(not self.esFeliz())
			self.sistemaImpositivo(apaciguador)
		else if(self.esFeliz() && imperio.tresCiudadesFelicesMenorCultura().contains(self)){
			self.sistemaImpositivo(incentivoCultural)
		}
		else{
			self.sistemaImpositivo(new Citadino(cadaCuantosHabitantes=25000))
		}
	}
	
	override method pepinesGenerados()=
		super() * 3
}

/*
 * Edificios-----------------------------------
 */
 class Edificio{
 	var property ciudad
 	var property costoDeConstruccionBase
 	method costoDeMantenimiento()=
 		self.costoDeConstruccion() *0.01
 	method ciudadFeliz()= ciudad.esFeliz()
 	method evolucionar(){
 		ciudad.cobrarAlImperio(self.costoDeMantenimiento())
 	}
 	method costoDeConstruccion()=
 		ciudad.costoDeConstruccion(self)
 		
 	method habitantesDeCiudad()=
 		ciudad.habitantes()
 		
 }
 
 class EdificioEconomico inherits Edificio{
 	const property pepinesGenerados
 	const property cultura =0
 	method tranquilidad() = 3
 	
 }
 
 class EdificioCultural inherits Edificio{
 	const property pepinesGenerados=0
 	const property cultura
 	method tranquilidad() = cultura * 3
 }
 
 class EdificioMilitar inherits Edificio{
 	const property pepinesGenerados=0
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
  
  class Citadino{
  	var property cadaCuantosHabitantes
  	
  	method agregado(edificio)= edificio.costoDeConstruccionBase() * 
  		(0.05 * edificio.habitantesDeCiudad().div(cadaCuantosHabitantes))
  }
  
  object incentivoCultural{
  	method agregado(edificio)= (- edificio.cultura().div(3))
  }
  
  object apaciguador{
  	method agregado(edificio) {
  		if(edificio.ciudadFeliz()){
  			return 0
  		}
  		else{
  			return (- edificio.tranquilidad())
  		}
  	}
  }
  
  /*
   * Excepciones
   */
   
   class ConstruccionFallida inherits Exception{}