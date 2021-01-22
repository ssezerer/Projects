import streamlit as st
import pickle
import pandas as pd

st.title('Telco Churn Prediction')
html_temp = """
<div style="background-color:tomato;padding:10px">
<h2 style="color:white;text-align:center;">Streamlit ML App </h2>
</div>"""
st.markdown(html_temp,unsafe_allow_html=True)

model = pickle.load(open("telco_model", "rb"))

tenure=st.sidebar.slider("Number of months the customer will stay with the company", 1, 72)
amount_monthly=st.sidebar.slider("The amount charged to the customer monthly", 18,120)
amount_total=st.sidebar.slider("The total amount charged to the customer", 18,8700)
contract=st.sidebar.selectbox("The contract term of the customer", ("month-to-month", "One year", "Two year"))
security=st.sidebar.selectbox("Whether the customer has online security or not", ("Yes", "No", "No internet service"))
internet_serv=st.sidebar.selectbox("Customer's internet service provider", ("Fiber optic", "DSL", "No"))
tech_support=st.sidebar.selectbox("Whether the customer has tec support or not", ("Yes", "No", "No internet service"))

my_dict = {"tenure": tenure,
           "InternetService": internet_serv,
           "OnlineSecurity": security,
           "TechSupport": tech_support,
           "Contract": contract,
           "MonthlyCharges": amount_monthly,
           "TotalCharges": amount_total
          }

df = pd.DataFrame.from_dict([my_dict])

columns = ['tenure', 'MonthlyCharges', 'TotalCharges',
       'InternetService_Fiber optic', 'InternetService_No',
       'OnlineSecurity_No internet service', 'OnlineSecurity_Yes',
       'TechSupport_No internet service', 'TechSupport_Yes',
       'Contract_One year', 'Contract_Two year']

df1 = pd.get_dummies(df).reindex(columns=columns, fill_value=0)

prediction = model.predict(df1)
prediction_proba = model.predict_proba(df1)


X = pd.read_csv("Telco_X.csv")
prediction_proba_all=model.predict_proba(X)

df_sel = pd.read_csv("Telco_df_sel.csv")
df_sel["Churn Probability"] = prediction_proba_all[:,0]
df_sel["Churn Probability"] = df_sel["Churn Probability"].apply(lambda x : round(x,4))

if st.checkbox("Churn Probability of Selected Customer"):
    st.markdown("### The features for Churn Prediction is below")
    st.table(df.head())
    st.markdown("### Press predict if features is okey")
    if st.button("Predict"):
        st.success("The Churn prediction is {}.".format(prediction[0]))
        st.success("The Churn probability of selected customer is {}.".format(round(prediction_proba[0][0],4)))

elif st.checkbox("Top Customers to Churn"):
    df_sel = df_sel.sort_values("Churn Probability", ascending = False)
    number=st.slider("Please select the number of top customers to churn", 0, 100, 1, step=5)
    if st.button("Show"):
        st.success(f"Top {number} customers to churn")
        st.table(df_sel.head(number))
        
elif st.checkbox("Top Loyal Customers"):
    df_sel = df_sel.sort_values("Churn Probability")
    number=st.slider("Please select the number of top customers to top loyal", 0, 100, 1, step=5)
    if st.button("Show"):
        st.success(f"Top {number} customers to loyal")
        st.table(df_sel.head(number))

elif st.checkbox("Churn Probability of Randomly Selected Customers"):
    number=st.slider("Please select the number of random customers to display", 0, 100, 1, step=5)
    if st.button("Show"):
        st.success(f"Random {number} customers to display")
        st.table(df_sel.sample(number))




