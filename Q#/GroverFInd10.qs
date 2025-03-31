namespace Quantum.GroverSearch {

    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;

    operation Main() : Result[] {
        
        Message("This example uses Grover's algorithm to find a marked state.");
        Message("The Grover's algorithm will search for the marked state |10⟩ through the following list of states:");
        Message("States: |00⟩, |01⟩, |10⟩, |11⟩, which correspond to integers 0, 1, 2, and 3 respectively.");
        Message("The marked state is |10⟩, which corresponds to the integer 2.");
        Message("Running Grover's algorithm...");
        // Number of qubits to use.
        // In this example, we will use 2 qubits to represent the states |00⟩, |01⟩, |10⟩, and |11⟩.
        // The marked state we want to find is |10⟩.
        // The marked state is represented by flipping the second qubit.
        // The marked state is |10⟩, which corresponds to the integer 2.
        // The other states are |00⟩ (0), |01⟩ (1), and |11⟩ (3).
        // The Grover's algorithm will search for the marked state |10⟩.
        // The number of qubits is 2, so we can represent the states as follows:
        // |00⟩ = 0
        // |01⟩ = 1
        // |10⟩ = 2 (marked state)
        // |11⟩ = 3
        // The Grover's algorithm will search for the marked state |10⟩.
        
        let nQubits = 2; // Two qubits for states [00, 01, 10, 11]
        Message($"Number of qubits: {nQubits}");
        let iterations = CalculateOptimalIterations(nQubits);
        Message($"Number of iterations: {iterations}");

        // Use Grover's algorithm to find the marked state |10⟩
        let results = GroverSearch(nQubits, iterations, ReflectAboutMarked);
        return results;
    }

    operation GroverSearch(
        nQubits : Int,
        iterations : Int,
        phaseOracle : Qubit[] => Unit) : Result[] {

        use qubits = Qubit[nQubits];

        PrepareUniform(qubits);

        for _ in 1..iterations {
            phaseOracle(qubits);
            ReflectAboutUniform(qubits);
        }

        // Measure and return the answer.
        return MResetEachZ(qubits);
    }

    function CalculateOptimalIterations(nQubits : Int) : Int {
        if nQubits > 63 {
            fail "This sample supports at most 63 qubits.";
        }
        let nItems = 1 <<< nQubits; // 2^nQubits
        let angle = ArcSin(1. / Sqrt(IntAsDouble(nItems)));
        let iterations = Round(0.25 * PI() / angle - 0.5);
        return iterations;
    }

    operation ReflectAboutMarked(inputQubits : Qubit[]) : Unit {
        Message("Reflecting about marked state...");
        use outputQubit = Qubit();
        within {
            // Initialize outputQubit to (|0⟩ - |1⟩)/√2
            X(outputQubit);
            H(outputQubit);
            // Apply X to qubit 1 to mark state |10⟩ (second qubit)
            X(inputQubits[1]);
        } apply {
            // Flip outputQubit if all inputQubits are |1⟩ (after X)
            Controlled X(inputQubits, outputQubit);
        }
    }

    operation PrepareUniform(inputQubits : Qubit[]) : Unit is Adj + Ctl {
        for q in inputQubits {
            H(q);
        }
    }

    operation ReflectAboutAllOnes(inputQubits : Qubit[]) : Unit {
        Controlled Z(Most(inputQubits), Tail(inputQubits));
    }

    operation ReflectAboutUniform(inputQubits : Qubit[]) : Unit {
        within {
            Adjoint PrepareUniform(inputQubits);
            for q in inputQubits {
                X(q);
            }
        } apply {
            ReflectAboutAllOnes(inputQubits);
        }
    }
}