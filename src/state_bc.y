%start ToplevelDecls
%avoid_insert "INT"
%%
ToplevelDecls -> Result<Vec<Toplevel>, Box<dyn Error>>:
	Toplevel { Ok(vec![$1?]) }
	| ToplevelDecls Toplevel { flatten( $1, $2 ) }
	;
Toplevel -> Result<Toplevel, Box<dyn Error>>:
	States { $1 }
	| EnumDecl { $1 }
	| Spawn { $1 }
	;

States -> Result<Toplevel, Box<dyn Error>>:
	'states' 'IDENTIFIER' '{' StatesContent '}' {
		Ok(Toplevel::States{name: $2?.span(), elements: $4?})
	}
	;

StatesContent -> Result<Vec<StateElement>, Box<dyn Error>>:
	StateElement { Ok(vec![$1?])}
	| StatesContent StateElement { flatten($1, $2) }  
	;

StateElement -> Result<StateElement,Box<dyn Error>>:
	'state' 'IDENTIFIER' ',' Bool ',' Expr ',' 'IDENTIFIER' ',' 'IDENTIFIER' ',' 'IDENTIFIER' {
		Ok(StateElement::State { sprite: $2?.span(), directional: $4?, timeout: $6?, think: $8?.span(), action: $10?.span(), next: $12?.span() })
	}
	| 'LABEL' {
		Ok(StateElement::Label ( $1?.span() ))
	}
	;

EnumDecl -> Result<Toplevel, Box<dyn Error>>:
	'enum' '{' EnumDeclContent '}' {
		Ok(Toplevel::EnumDecl($3?))
	}
	;

EnumDeclContent -> Result<Vec<Span>,Box<dyn Error>>:
	'IDENTIFIER' { Ok(vec![$1?.span()])}
	| EnumDeclContent ',' 'IDENTIFIER' { flatten($1,Ok($2?.span()))	}
	;
	
Spawn -> Result<Toplevel, Box<dyn Error>>:
	'spawn' 'IDENTIFIER' '{' SpawnDecl '}' {
		Ok(Toplevel::Spawn{ name: $2?.span(), elements: $4? })
	}
	;
	
SpawnDecl -> Result<Vec<SpawnDeclElement>,Box<dyn Error>>:
	SpawnDeclElement { Ok(vec![$1?])}
	| SpawnDecl SpawnDeclElement { flatten($1,$2) }
	;

SpawnDeclElement -> Result<SpawnDeclElement, Box<dyn Error>>:
	'directional' Expr ',' 'IDENTIFIER' ',' 'IDENTIFIER' {
		Ok(SpawnDeclElement { directional: true, id: $2?, state: $4?.span(), drop: $6?.span() })
	}
	| 'undirectional' Expr ',' 'IDENTIFIER' ',' 'IDENTIFIER' {
		Ok(SpawnDeclElement { directional: false, id: $2?, state: $4?.span(), drop: $6?.span() })
	}
	;

Expr -> Result<u64, Box<dyn Error>>:
	Expr '+' Term {
		Ok($1? + $3?)
	}
	| Term {
		$1
	}
	;

Term -> Result<u64, Box<dyn Error>>:
	'INT' {
        parse_int($lexer.span_str($1.map_err(|_| "<evaluation aborted>")?.span()))
	}
	| '(' Expr ')' {
		$2
	}
	;
Bool -> Result<bool, Box<dyn Error>>:
	'true' {
		Ok(true)
	}
	| 'false' {
		Ok(false)
	}
	;
%%
// Any imports here are in scope for all the grammar actions above.

use std::error::Error;
use cfgrammar::Span;

fn flatten<T>(lhs: Result<Vec<T>, Box<dyn Error>>, rhs: Result<T, Box<dyn Error>>)
           -> Result<Vec<T>, Box<dyn Error>>
{
    let mut flt = lhs?;
    flt.push(rhs?);
    Ok(flt)
}

fn parse_int(s: &str) -> Result<u64, Box<dyn Error>> {
    match s.parse::<u64>() {
        Ok(val) => Ok(val),
        Err(_) => {
            Err(Box::from(format!("{} cannot be represented as a u64", s)))
        }
    }
}

#[derive(Debug)]
pub enum Toplevel {
	States{name: Span, elements: Vec<StateElement>},
	Spawn{name: Span, elements: Vec<SpawnDeclElement> },
	EnumDecl(Vec<Span>)
}
#[derive(Debug)]
pub enum StateElement {
	State { sprite: Span, directional: bool, timeout: u64, think: Span, action: Span, next: Span},
	Label(Span)
}
#[derive(Debug)]
pub struct SpawnDeclElement {
	directional: bool,
	id: u64,
	state: Span,
	drop: Span,
}