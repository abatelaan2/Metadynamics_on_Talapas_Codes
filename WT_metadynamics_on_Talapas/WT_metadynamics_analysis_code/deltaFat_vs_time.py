import numpy as np
import glob
import re
import matplotlib.pyplot as plt

# Lists to store data
sample_sizes = []
deltaFs = []

# Loop over all files numerically
for filename in sorted(glob.glob("fes_rew__*.dat"), key=lambda x: int(re.findall(r'\d+', x)[0])):
    with open(filename, "r") as f:
        content = f.read()
        
        # Extract sample_size
        sample_match = re.search(r"#! SET sample_size (\d+\.?\d*)", content)
        sample_size = float(sample_match.group(1)) if sample_match else np.nan
        
        # Extract DeltaF
        deltaF_match = re.search(r"#! SET DeltaF (-?\d+\.?\d*)", content)
        deltaF = float(deltaF_match.group(1)) if deltaF_match else np.nan
        
        # Append to lists
        sample_sizes.append(sample_size)
        deltaFs.append(deltaF)

# Convert to 2D NumPy array (columns: sample_size, DeltaF)
data_array = np.column_stack((sample_sizes, deltaFs))

# Save as .npy file
np.save("sample_DeltaF.npy", data_array)
print("Data saved to sample_DeltaF.npy")

# Plot DeltaF vs sample_size
plt.figure(figsize=(8,5))
plt.plot(data_array[:,0], data_array[:,1], "o-", color="blue")
plt.xlabel("Time (ps)")
plt.ylabel("DeltaF (kJ/mol)")
plt.title("DeltaF vs Sample Size")
#plt.grid(True)
#plt.show()
plt.savefig("DeltaF_vs_time.png")
plt.close()
