use std::io::{self, BufRead, Read};

use lrlex::lrlex_mod;
use lrpar::{lrpar_mod, Lexer};

lrlex_mod!("state_bc.l");
lrpar_mod!("state_bc.y");

fn main() {
    let lexerdef = state_bc_l::lexerdef();
    let stdin = io::stdin();
    let mut input = Vec::new();
    stdin.lock().read_to_end(&mut input).unwrap();

    let input = String::from_utf8(input).unwrap();
    let lexer = lexerdef.lexer(&input);

    let (res, errs) = state_bc_y::parse(&lexer);
    for e in errs {
        println!("{}", e.pp(&lexer, &state_bc_y::token_epp));
    }
    match res {
        Some(Ok(r)) => println!("Result: {:?}", r),
        Some(Err(e)) => eprintln!("{}", e),
        _ => eprintln!("Unable to evaluate expression."),
    }
    // loop {
    //     println!(">>>");
    //     let Some(Ok(line))= stdin.lock().lines().next() else { break; };
    //     if line.trim().is_empty() {
    //         break;
    //     }
    //     let lexer = lexerdef.lexer(&line);
    //     // for x in lexer.iter() {
    //     //     println!("{x:?}");
    //     // }
    //     let (res, errs) = state_bc_y::parse(&lexer);
    //     for e in errs {
    //         println!("{}", e.pp(&lexer, &state_bc_y::token_epp));
    //     }
    //     match res {
    //         Some(Ok(r)) => println!("Result: {:?}", r),
    //         Some(Err(e)) => eprintln!("{}", e),
    //         _ => eprintln!("Unable to evaluate expression."),
    //     }
    //     // lexer.
    // }
}
