//
//  ContentView.swift
//  DailyBudget
//
//  Created by Facundo Vogel on 27/12/2025.
//
// Permite calcular cuanto dinero te queda disponible en el dia segun tu presupuesto y tus gastos, ademas te permite ir visualizando esos gastos a traves de un listado scrolleable que contiene nombre del producto y su precio correspondiente.

import SwiftUI

extension String {
    func trimmed() -> String {
        self.trimmingCharacters(in: .newlines)
    }
    
    mutating func trim() {
        self = self.trimmed()
    }
}

struct Headline: ViewModifier {
    
    func body (content: Content) -> some View {
        
        content
            .padding(.leading, 15)
            .frame(maxWidth: .infinity, minHeight: 30)
            .background(.thinMaterial.opacity(0.5))
            .clipShape(.rect(cornerRadius: 20))
            .padding(20)
    }
}

extension View {
    func headlineStyle() -> some View {
        modifier(Headline())
    }
}

struct ContentView: View {
    @State private var presupuestoDiario = 100.0

    @State private var gastos = [String: Double]()
    
    @State private var nuevoGastoNombre: String = ""
    @State private var nuevoGastoMonto: Double = 0.0
    
    @FocusState private var fieldIsFocused: Bool
    
    var dineroDisponible: Double {
        
        let gastosValores = Array(gastos.values)
        var sumaGastos = 0.0
        
        for gastoValor in gastosValores {
            sumaGastos += gastoValor
        }
        
        if sumaGastos <= presupuestoDiario {
            return presupuestoDiario - sumaGastos
        } else {
            return 0.0
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                RadialGradient(stops: [
                    .init(color: Color(red: 0.1, green: 0.4, blue: 0.4), location: 0.3),
                    .init(color: Color(red: 0.2, green: 0.6, blue: 0.5), location: 0.38)
                    ], center: .top, startRadius: 200, endRadius: 700)
                    .ignoresSafeArea()
                ScrollView {
                    VStack {
                        
                        Text("Ingrese su presupuesto de hoy")
                            .padding(.top, 15)
                            .font(.headline)
                            .foregroundStyle(.white)
                        
                        TextField("Presupuesto de hoy", value: $presupuestoDiario, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                            .keyboardType(.decimalPad)
                            .headlineStyle()
                            .focused($fieldIsFocused)

                        Text("Escriba el nombre del gasto")
                            .padding(.top, 5)
                            .font(.headline)
                            .foregroundStyle(.white)
                        
                        TextField("Ej: Comida",text: $nuevoGastoNombre)
                            .font(.headline.weight(.bold))
                            .keyboardType(.alphabet)
                            .headlineStyle()
                            .focused($fieldIsFocused)
                        
                        Text("Escriba el monto del gasto")
                            .padding(.top, 5)
                            .font(.headline)
                            .foregroundStyle(.white)
                        
                        TextField("Monto del gasto", value: $nuevoGastoMonto, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                            .keyboardType(.decimalPad)
                            .headlineStyle()
                            .focused($fieldIsFocused)
                        
                        Text("Listado de gastos")
                            .padding(.top, 5)
                            .font(.headline)
                            .foregroundStyle(.white)
                        
                        HStack {

                            Text("Producto")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.white)
                            
                            Text("Precio")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .foregroundStyle(.white)
                            
                        }
                        .padding(.horizontal)
                        
                        ScrollView {
                            VStack(spacing: 10) {
                                
                                if gastos.isEmpty {
                                    Text("No hay gastos registrados")
                                        .foregroundStyle(.black.opacity(0.7))
                                        .fontWeight(.semibold)
                                        .padding(30)
                                } else {
                                    ForEach(gastos.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                        HStack {
                                            
                                            Image(systemName: "cart")
                                                .font(.system(size: 18))
                                                .foregroundColor(.black.opacity(0.7))

                                            Text(key)
                                                .foregroundStyle(.black.opacity(0.7))
                                                .fontWeight(.semibold)
                                            
                                            Spacer()
                                            
                                            Text("$\(value, specifier: "%.2f")")
                                                .foregroundStyle(.black.opacity(0.7))
                                                .fontWeight(.semibold)
                                            
                                        }
                                        .padding(.vertical, 2)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .background(.thinMaterial.opacity(0.5))
                            .clipShape(.rect(cornerRadius: 20))
                            
                        }
                        .frame(height: 120)
                        .padding(.horizontal, 20)
                        
                        Button("Agregar al listado") {
                            nuevoGastoNombre.trim()
                            addNewGasto(nombre: nuevoGastoNombre, monto: nuevoGastoMonto)
                        }
                        .frame(height: 44)
                        .frame(maxWidth: 200)
                        .background(
                            LinearGradient( colors: [Color(red: 0.15, green: 0.5, blue: 0.5),
                                                     Color(red: 0.1, green: 0.4, blue: 0.4)],
                                            startPoint: .top, endPoint: .bottom)
                        )
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                        .clipShape(.rect(cornerRadius: 15))
                        .shadow(radius: 5)
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                        
                        Text("Dinero restante: $\(dineroDisponible, specifier: "%.2f")")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(dineroDisponible == 0 ? .red : .white)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(.rect(cornerRadius: 15))
                        
                    }
                }
            }
            .navigationTitle("DailyBudget")
            .toolbar {
                if fieldIsFocused {
                    Button("Listo") {
                        fieldIsFocused = false
                    }
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    func addNewGasto (nombre: String, monto: Double) {
        
        let nombreMinusculas = nombre.lowercased()
        var claveExistente: String? = nil
        
        if nombre != "" && monto != 0.0 {
            
            for clave in gastos.keys {
                if clave.lowercased() == nombreMinusculas {
                    claveExistente = clave
                    break
                }
            }
            
            if let clave = claveExistente {
                gastos[clave]! += monto
            } else {
                gastos[nombre] = monto
            }
        }
        
        nuevoGastoNombre = ""
        nuevoGastoMonto = 0.0
        fieldIsFocused = false
    }
}

#Preview {
    ContentView()
}
