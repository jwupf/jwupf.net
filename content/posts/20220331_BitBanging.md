---
title: "Bit Banging"
date: 2022-03-31T21:26:39+02:00
draft: false
---

Hm, die Sache mit dem Datum muss man noch üben. Gestern war definitiv nicht der 20.März, ehrlich!

Der heutige Artikel wird eher kurz, aber ich übe ja noch.

Hab ein bisschen mit Rust gespielt und dabei ist dieses kleine Beispiel raus gekommen in dem ein Bit in einem Byte gesetzt oder gelöscht wird.

````rust
pub fn set_bit(byte: &mut u8, bit: u8){    
    *byte = (*byte) | (1 << bit);
}

pub fn unset_bit(byte: &mut u8, bit: u8){    
    *byte = (*byte) ^ (1 << bit);
}

#[cfg(test)]
mod bit_bang_tests {    
    use super::*;

    #[test]
    fn test_set_bit() {
        let mut value = 0;
        let bit = 3;

        set_bit(&mut value,bit);
        
        assert_eq!(value,8);
    }

    #[test]
    fn test_unset_bit() {
        let mut value:u8 = 2;
        let bit:u8 = 1;
        
        unset_bit(&mut value, bit);
        
        assert_eq!(value, 0);
    }
}
````

Die Funktionen nehmen eine veränderliche Referenz zum zu manipulierenden Wert(*byte*) und die Bitnummer(*bit*) als Parameter.

Der Test zum setzen will das Bit **3**(bit) im Wert **0**(value) setzen. Mit *assert_eq* wird dann geprüft ob der neue Wert **8**(*2^3*) ist.

Der Test zum löschen will das Bit **1**(bit) im Wert **2**(value) löschen. Mit *assert_eq* wird dann geprüft ob der neue Wert **0** ist.

Der Wertebereich der Variable ``bit`` wird nicht geprüft. Das macht das Beispiel nur unübersichtlich. Die kann man aber mit der Hilfe von ``mem::size_of::<u8>()`` machen. Dann muss man sich aber auch überlegen wie man mit Fehlern umgeht ... ziemlich viel aufwand um ein bit zu setzen. Aber ich probier es mal:

````rust
use std::mem;
use std::error::Error;

pub fn set_bit(byte: &mut u8, bit: u8)->Result<(),Box<dyn Error>> {
    let value_length = 8 * mem::size_of::<u8>() as u8;
    if bit >= value_length {        
        return Err(format!("Error: not enough bits in a byte. Expected a value between 0 and 7, but got {bit}").into());
    }
    *byte = (*byte) | (1 << bit);
    Ok(())
}

pub fn unset_bit(byte: &mut u8, bit: u8)->Result<(),Box<dyn Error>> {    
    let value_length = 8 * mem::size_of::<u8>() as u8;
    if bit >= value_length {        
        return Err(format!("Error: not enough bits in a byte. Expected a value between 0 and 7, but got {bit}").into());
    }
    *byte = (*byte) ^ (1 << bit);
    Ok(())
}

#[cfg(test)]
mod bit_bang_tests {    
    use super::*;

    #[test]
    fn test_set_bit() {
        let mut value = 0;
        let bit = 3;
        
        let result = set_bit(&mut value,bit);
        
        assert!(result.is_ok());        
        assert_eq!(value,8);
    }

    #[test]
    fn test_set_bit_outside_a_byte() {
        let mut value = 0;
        
        let bit = 9;
        let result = set_bit(&mut value,bit);

        assert!(result.is_err());                
    }

    #[test]
    fn test_unset_bit() {
        let mut value:u8 = 2;
        let bit:u8 = 1;
        
        let result = unset_bit(&mut value, bit);
        
        assert!(result.is_ok());  
        assert_eq!(value, 0);
    }

    #[test]
    fn test_unset_bit_outside_a_byte() {
        let mut value:u8 = 2;
        let bit:u8 = 12;
        
        let result = unset_bit(&mut value, bit);
        
        assert!(result.is_err());          
    }
}
````

Das ist besser, aber echt nicht mehr einfach zu lesen. Mal sehen ob ich da noch was besseres finde. Und wenn das ein kurzer Artikel ist hab ich Angst 🙄🤣😅.