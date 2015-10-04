library tristate;

class Tri extends Object with Tristate {
  //Construct the only 3 possible Tristate objects
  static final Tri FALSE = new Tri._base(0);
  static final Tri BOTH = new Tri._base(1);
  static final Tri TRUE = new Tri._base(2);
  
  //Define the truth tables of the basic Tristate operators
  static final List<List<Tri>> _AND = [[FALSE, FALSE, FALSE],
                                       [FALSE, BOTH,  BOTH],
                                       [FALSE, BOTH,  TRUE]];
  
  static final List<List<Tri>> _OR = [[FALSE, BOTH, TRUE],
                                      [BOTH,  BOTH, TRUE],
                                      [TRUE,  TRUE, TRUE]];
  
  static final List<List<Tri>> _XOR = [[FALSE, BOTH, TRUE],
                                       [BOTH,  BOTH, BOTH],
                                       [TRUE,  BOTH, FALSE]];
  
  static final List<List<bool>> _LOG_EQU = [[true,  false, false],
                                            [false, false, false],
                                            [false, false, true]];
  
  static final List<Tri> _NOT = [TRUE, BOTH, FALSE];
  
  //Data members
  final int asInt;
  Tri get asTri => this;
  
  //Constructor
  Tri._base(this.asInt); //Tristates will never be constructed outside the class  
}

abstract class Tristate {
  Tri get asTri;
  
  Tristate operator &(Tristate t) => Tri._AND[asTri.asInt][t.asTri.asInt];
  Tristate operator |(Tristate t) => Tri._OR [asTri.asInt][t.asTri.asInt];
  Tristate operator ^(Tristate t) => Tri._XOR[asTri.asInt][t.asTri.asInt];
  Tristate operator -()           => Tri._NOT[asTri.asInt];
  
  bool logicallyEqual(Tristate t) => Tri._LOG_EQU[asTri.asInt][t.asTri.asInt];
}