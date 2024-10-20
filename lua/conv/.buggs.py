import matplotlib.pyplot as plt

import numpy as np



time_averaged = [3.006, 2.542, 2.112, 1.839, 2.773, 1.646, 2.328, 1.965, 1.255]

delta_x = [0.4694, 0.3995, 0.3, 0.1994, 0.4338, 0.149, 0.3536, 0.2493, 0.0975]

num_trials = [20, 20, 20, 20, 5, 5, 5, 5, 5]

time_squared = []

for value in time_averaged:

    time_squared.append(value ** 2)

print('VTNB END OF CODEBLOCK 1')
standard_error_time = []



data_values1 = [

    2.998, 3.039, 3.025, 2.962, 2.98, 2.985, 3.01, 2.999, 3.13, 2.996, 2.996, 3.01, 

    3.098, 2.941, 3.033, 2.978, 2.971, 2.949, 2.997, 3.015, 2.516, 2.535, 2.53, 2.5, 

    2.515, 2.522, 2.447, 2.503, 2.543, 2.549, 2.55, 2.587, 2.532, 2.576, 2.584, 2.57, 

    2.588, 2.56, 2.545, 2.595, 2.108, 2.091, 2.069, 2.097, 2.094, 2.11, 2.091, 2.099, 

    2.088, 2.067, 2.103, 2.111, 2.115, 2.163, 2.116, 2.109, 2.175, 2.096, 2.126, 2.22, 

    1.812, 1.819, 1.796, 1.847, 1.811, 1.9, 1.826, 1.836, 1.848, 1.885, 1.742, 1.853, 

    1.845, 1.833, 1.879, 1.866, 1.848, 1.877, 1.797, 1.86, 2.782, 2.764, 2.761, 

    2.758, 2.802, 1.672, 1.617, 1.647, 1.646, 1.648, 2.371, 2.325, 2.3, 2.296, 2.347, 

    1.969, 1.985, 1.955, 1.957, 1.961, 1.281, 1.331, 1.256, 1.234, 1.174

]



data_values = np.array(data_values1)





trial_1 = data_values[:20]

trial_2 = data_values[20:40]

trial_3 = data_values[40:60]

trial_4 = data_values[60:80]

trial_5 = data_values[80:85]

trial_6 = data_values[85:90]

trial_7 = data_values[90:95]

trial_8 = data_values[95:100]

trial_9 = data_values[100:105]



for i in range(1, 10):

    trial_key = f'trial_{i}'  # Construct the trial name

    trial_data = locals()[trial_key]  # Access the trial list using locals()

    

    # Calculate standard error and append to the list

    standard_error_time.append((np.std(trial_data, ddof=1) / np.sqrt(len(trial_data))))

    #standard_error_time.append(.25 / np.sqrt(len(trial_data)))





print(f"our standard error values for each averaged time is: {standard_error_time}")







print('VTNB END OF CODEBLOCK 2')
def PropPower(A,dA,n):

	Z = A**n

	return abs(n*Z*(dA/A))

standard_error_time_squared = PropPower(np.array(time_averaged), np.array(standard_error_time),2)

print(standard_error_time_squared)
print('VTNB END OF CODEBLOCK 3')
import numpy as np
import numpy
import matplotlib.pyplot as plt

plt.rcParams['font.family'] = 'serif'
plt.rcParams['text.usetex'] = True
plt.rcParams['font.size'] = 14  # Set overall font size to 14

# Fit the data
slope, intercept = np.polyfit(delta_x, time_squared, 1)

# Generate best-fit line data
x_best_fit = np.linspace(min(delta_x), max(delta_x), 100)
y_best_fit = intercept + x_best_fit * slope

# Calculate residuals
residuals = np.array(time_squared) - (intercept + np.array(delta_x) * slope)

# Create figure and subplots
fig, (ax1, ax2) = plt.subplots(2, 1, gridspec_kw={'height_ratios': [3, 1]}, figsize=(8, 6))

# First plot: Best-fit line and data points
ax1.errorbar(delta_x, time_squared, xerr=0.0005, yerr=standard_error_time_squared, 
             fmt="x", ecolor="blue", label="Data with error bars", capsize=5, color="red")
ax1.plot(x_best_fit, y_best_fit, label="Line of Best Fit", color="orange")
ax2.set_xlabel("Distance Traveled (m)")

ax1.set_ylabel("Change in Time Squared (s$^2$)")
ax1.set_title("Time Squared vs Distance Travelled")
ax1.legend()

# Second plot: Residuals
ax2.scatter(delta_x, residuals-0.04, color='red', label='Residuals')
ax2.axhline(0, color='gray', linestyle='--', linewidth=0.8)  # Add horizontal line at zero
ax2.set_ylabel("Residuals")

ax2.errorbar(delta_x, residuals-0.04, xerr=0.0005, yerr=standard_error_time_squared, 
	fmt="x", ecolor="blue", label="Data with error bars", capsize=5, color="red")
#ax2.legend(loc="upper left")

# Adjust spacing between subplots
plt.tight_layout()

# Show the plot
plt.savefig('.figure-1.png'); print('VTNB FIGURE-1') # plt.show()

# Output the slope and intercept
print(f"The slope is: {slope:.5f} and the intercept is: {intercept:.4f}")



from scipy.stats import chi2
# Degrees of freedom
degrees_of_freedom = len(delta_x) - 2  # 2 parameters estimated (slope and intercept)

# Calculate chi-squared statistic 
chi_squared = np.sum((residuals / (5* standard_error_time_squared)) ** 2)

# Calculate p-value 
p_value = 1 - chi2.cdf(chi_squared, degrees_of_freedom)

print(f"Chi-squared statistic: {chi_squared:.3f}")
print(f"P-value: {p_value:.921f}")

# Interpretation:
if p_value > 0.05:
    print("The fit is considered good. No reason to reject the model.")
elif p_value < 0.05 and p_value > 1e-3:
    print("The fit is questionable. Further investigation might be needed.")
else:  # p_value < 1e-3
    print("The fit is considered poor. The model is likely incorrect.")



print('VTNB END OF CODEBLOCK 4')

print('VTNB END OF CODEBLOCK 5')
