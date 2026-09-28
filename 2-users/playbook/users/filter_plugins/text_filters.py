#!/usr/bin/env python3

class FilterModule(object):
    def filters(self):
        return {
            'clean_text': self.clean_text
        }

    def clean_text(self, text):
        """Elimina acentos y convierte la ñ/Ñ en n/N"""
        if not isinstance(text, str):
            return text
            
        # Diccionario con las sustituciones de tus comandos sed
        tablas_reemplazo = str.maketrans({
            'Á': 'a', 'á': 'a',
            'É': 'e', 'é': 'e',
            'Í': 'i', 'í': 'i',
            'Ó': 'o', 'ó': 'o',
            'Ú': 'u', 'ú': 'u',
            'Ñ': 'n', 'ñ': 'n'
        })
        
        return text.translate(tablas_reemplazo)

