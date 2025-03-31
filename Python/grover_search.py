from azure.quantum import Workspace
from azure.quantum.qiskit import AzureQuantumProvider
from qiskit_algorithms import Grover
from qiskit_algorithms import AmplificationProblem
from qiskit import QuantumCircuit, Aer, execute
from qiskit import QuantumCircuit
from qiskit_aer import Aer


# 1. Connexion à Azure Quantum
workspace = Workspace(
    resource_id="/subscriptions/9dcca2c0-5f6f-4aa7-aefc-78db333c3763/resourceGroups/AzureQuantum",  # Remplacez par votre Resource ID
    location="westeurope"         # Remplacez par votre Location
)
provider = AzureQuantumProvider(workspace)

# 2. Création du circuit pour rechercher "10" parmi ["00", "01", "10", "11"]
oracle = QuantumCircuit(2)
oracle.cz(0, 1)  # Marquer l'état "10"

# Ajouter des mesures au circuit oracle
oracle.measure_all()

# Définir le problème pour Grover
problem = AmplificationProblem(oracle)

# Initialiser l'algorithme de Grover
grover = Grover()

# Résoudre le problème
result = grover.solve(problem)

# 3. Exécuter sur un simulateur IonQ
backend = provider.get_backend("ionq.simulator")
job = backend.run(result.circuit)  # Utiliser le circuit généré par Grover
print("Résultat:", job.result().get_counts())
