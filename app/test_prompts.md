# Tata Neu Assistant - Test Prompts & Customer Personas

## 📋 Customer Database Summary

| Customer ID | Name | City | Tier | NeuCoins | Key Scenarios |
|-------------|------|------|------|----------|---------------|
| NEU001 | Rajesh Sharma | Bangalore | Gold | 15,250 | Delivery delay, Return request, Active card |
| NEU002 | Priya Patel | Mumbai | Platinum | 45,000 | Out for delivery order, EMI query, High-value purchase |
| NEU003 | Amit Singh | Delhi | Silver | 8,500 | Payment issue (double deduction), Processing order |
| NEU004 | Neha Gupta | Kolkata | Bronze | 2,500 | Defective product, Refund completed |
| NEU005 | Vikram Joshi | Hyderabad | Gold | 12,000 | Placed order (pending payment), Flight booking |
| NEU006 | Ananya Iyer | Chennai | Platinum | 32,000 | Active card, High spender |
| NEU007 | Suresh Kumar | Pune | Silver | 6,800 | **BLOCKED card**, ₹2.5L outstanding |
| NEU008 | Kavita Reddy | Bangalore | Bronze | 1,200 | Pending card activation |

---

## 🎯 Test Scenarios by Category

### 1️⃣ Order Status Queries

**Customer: Rajesh Sharma (NEU001)**
```
"मेरा ऑर्डर कहाँ है? ORD001002"
"My order ORD001002 is delayed, when will it arrive?"
"मुझे मेरे सभी ऑर्डर दिखाओ"
```
Expected: Order shipped, tracking CR987654321, est. delivery Jan 22

**Customer: Priya Patel (NEU002)**
```
"मेरा Tanishq नेकलेस कब आएगा?"
"Where is my gold necklace order?"
"Order ORD002001 ka status batao"
```
Expected: Out for delivery, should arrive Jan 21

**Customer: Amit Singh (NEU003)**
```
"ORD003001 ka status kya hai?"
"मेरा Croma order कब तक process होगा?"
```
Expected: Processing, est. delivery Jan 23

---

### 2️⃣ Return & Refund Scenarios

**Customer: Rajesh Sharma (NEU001)**
```
"मुझे अपना jacket return करना है, साइज़ फिट नहीं हुआ"
"ORD001003 के लिए return pickup schedule करो"
"मेरा return request का status क्या है?"
```
Expected: Return already requested, pickup pending

**Customer: Neha Gupta (NEU004)**
```
"मेरा Bluetooth speaker खराब निकला था, refund कहाँ है?"
"ORD004002 ka refund ho gaya kya?"
```
Expected: Refund completed for ₹8,000

**Customer: Priya Patel (NEU002)**
```
"मैंने Titan watch cancel किया था, पैसे वापस आए?"
"ORD002003 cancellation status"
```
Expected: Cancelled order, refunded

---

### 3️⃣ NeuCard Queries

**Customer: Rajesh Sharma (NEU001) - Active Neu Infinity**
```
"मेरे card का balance क्या है?"
"Credit limit kitna bacha hai?"
"मेरी due date कब है?"
"Last 5 transactions दिखाओ"
```
Expected: ₹75,000 outstanding, ₹4,25,000 available, due Feb 15

**Customer: Priya Patel (NEU002) - High-value Neu Infinity**
```
"Tanishq purchase को EMI में convert करो"
"12 महीने की EMI बनाओ"
"मेरा card statement चाहिए"
```
Expected: ₹1,50,000 outstanding, ₹1,25,000 Tanishq purchase, EMI conversion

**Customer: Suresh Kumar (NEU007) - BLOCKED Card**
```
"मेरा card काम नहीं कर रहा"
"Card block kyu hai?"
"मुझे card unblock करना है"
```
Expected: Card blocked, ₹2,50,000 outstanding (full balance due), needs immediate payment

**Customer: Kavita Reddy (NEU008) - Pending Activation**
```
"मेरा नया card activate karo"
"Card activation kaise hoga?"
```
Expected: Neu HipCard pending activation, ₹50,000 limit

---

### 4️⃣ NeuCoins Queries

**Customer: Priya Patel (NEU002) - Platinum, High Balance**
```
"मेरे कितने NeuCoins हैं?"
"NeuCoins कैसे use करूँ?"
"मुझे Republic Day bonus मिला?"
```
Expected: 45,000 NeuCoins, got 500 bonus coins

**Customer: Rajesh Sharma (NEU001)**
```
"मेरे NeuCoins balance"
"BigBasket order पर कितने coins मिले?"
```
Expected: 15,250 coins, earned 255 from last order

---

### 5️⃣ Support Ticket Scenarios

**Customer: Rajesh Sharma (NEU001)**
```
"मेरी delivery delay complaint का क्या हुआ?"
"Ticket TKT001001 update दो"
```
Expected: In progress, assigned to Delivery Team

**Customer: Amit Singh (NEU003)**
```
"पैसे दो बार कट गए! Help!"
"Payment double deduct हो गया"
"ORD003001 के लिए refund चाहिए"
```
Expected: High priority ticket in progress with Payment Team

---

### 6️⃣ Complex Multi-intent Queries

**Customer: Rajesh Sharma (NEU001)**
```
"मेरे ऑर्डर का status बताओ और साथ में card balance भी"
"TV order कब आएगा और क्या मैं return कर सकता हूँ jacket?"
```

**Customer: Priya Patel (NEU002)**
```
"Gold necklace delivery status और EMI conversion दोनों करो"
"मेरे total NeuCoins और आज की orders दिखाओ"
```

---

### 7️⃣ Edge Cases & Error Handling

**Invalid Customer**
```
"मेरा customer ID NEU999 है"
"Order ORD999999 ka status"
```
Expected: Customer/Order not found, ask for valid details

**Ambiguous Queries**
```
"मुझे help चाहिए"
"कुछ problem है"
"मेरा order"
```
Expected: Ask clarifying questions

**Language Switch**
```
"Start in Hindi, then switch: मेरा order... actually tell me in English"
"Order status in Hindi please"
```

---

## 🗣️ Sample Conversation Flows

### Flow 1: Complete Order Journey
```
User: "नमस्ते, मैं Rajesh Sharma हूँ"
Bot: Greets, identifies customer NEU001

User: "मेरा Croma TV order कब आएगा?"
Bot: Order ORD001002 shipped, tracking CR987654321, arriving Jan 22

User: "और मेरे NeuCoins?"
Bot: 15,250 NeuCoins available

User: "धन्यवाद"
Bot: Polite closing
```

### Flow 2: Card Issue Resolution
```
User: "मैं Suresh Kumar, मेरा card decline हो रहा है"
Bot: Identifies blocked card CARD007

User: "क्यों block है?"
Bot: Outstanding ₹2,50,000, minimum due ₹2,50,000 (full balance)

User: "कैसे unblock होगा?"
Bot: Pay outstanding balance, provides payment options
```

### Flow 3: Return Request
```
User: "मैं Neha Gupta, मुझे speaker return करना है"
Bot: Identifies customer NEU004

User: "ORD004002 defective था"
Bot: Already processed - refund completed for ₹8,000

User: "धन्यवाद, NeuCoins balance बताओ"
Bot: 2,500 NeuCoins available
```

---

## 📱 Quick Reference - Phone Numbers for Testing

| Customer | Phone | Language Pref |
|----------|-------|---------------|
| Rajesh Sharma | +91-9876543210 | Hindi |
| Priya Patel | +91-9988776655 | English |
| Amit Singh | +91-8877665544 | Hindi |
| Neha Gupta | +91-7766554433 | English |
| Suresh Kumar | +91-9944332211 | Marathi |

---

## ✅ Verification Checklist

- [ ] Order status lookup works
- [ ] Return/refund queries handled
- [ ] NeuCard balance & transactions
- [ ] NeuCoins balance & history
- [ ] Blocked card scenario
- [ ] Support ticket status
- [ ] Hindi responses natural & feminine
- [ ] Multi-intent queries resolved
- [ ] Error handling graceful
