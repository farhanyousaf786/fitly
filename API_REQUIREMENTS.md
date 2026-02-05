# 🚀 Fitly App - API Requirements

## ✅ **IMPLEMENTED FLOW**

```
1. Splash Screen (2 sec)
   ↓
2. Onboarding Slides (3 slides) ← Show value!
   ↓
3. AI Chat Screen ← User chats with AI (NO LOGIN REQUIRED!)
   ↓
4. Plan Summary Screen ← Shows generated plan
   ↓
5. Signup/Login ← Now user wants to save the plan!
   ↓
6. Dashboard ← Personalized plan ready
```

---

## 📡 **APIS YOU NEED TO BUILD**

### **1. AI Chat API** (Most Important!)

**Endpoint**: `POST /api/ai/chat`

**Purpose**: Process user messages and generate responses

**Request**:
```json
{
  "message": "30 male, belly fat, eat 2 parathas morning...",
  "conversation_history": [
    {
      "role": "user",
      "content": "I want to lose weight"
    },
    {
      "role": "assistant",
      "content": "Great! Tell me more about your current lifestyle..."
    }
  ]
}
```

**Response**:
```json
{
  "response": "I understand you want to lose belly fat. How much time can you dedicate to exercise daily?",
  "extracted_data": {
    "age": 30,
    "gender": "male",
    "goal_type": "weight_loss",
    "body_type": "belly_fat",
    "current_diet": "high_carbs",
    "exercise_level": "none"
  },
  "is_complete": false
}
```

---

### **2. Generate Plan API**

**Endpoint**: `POST /api/ai/generate-plan`

**Purpose**: Create complete personalized plan from extracted data

**Request**:
```json
{
  "user_data": {
    "age": 30,
    "gender": "male",
    "goal_type": "weight_loss",
    "body_type": "belly_fat",
    "lifestyle": "sedentary",
    "current_diet": "high_carbs",
    "wake_time": "07:00",
    "sleep_time": "23:00",
    "intensity": "fast"
  }
}
```

**Response**:
```json
{
  "user_config": {
    "goal_type": "weight_loss",
    "goal_title": "Lose Belly Fat",
    "target_description": "8-10 kg in 12 weeks",
    "intensity": "fast",
    
    "ui_config": {
      "show_calories": false,
      "show_protein_tracker": false,
      "emphasis_sections": ["diet", "water", "cardio"],
      "exercise_difficulty": "beginner"
    },
    
    "diet_plan": {
      "meals": [
        {
          "name": "Breakfast",
          "time": "07:30",
          "foods": ["2 boiled eggs", "black tea (no sugar)"],
          "avoid": ["parathas", "sugar"],
          "instructions": "Boil eggs for 8 minutes...",
          "why_it_works": "Protein keeps you full, no carbs = burn fat",
          "calories": 200,
          "show_instructions": true
        },
        {
          "name": "Lunch",
          "time": "13:00",
          "foods": ["1 roti", "grilled chicken 150g", "salad", "yogurt"],
          "avoid": ["extra rotis", "fried chicken", "rice"],
          "calories": 450
        }
      ],
      "diet_restrictions": ["reduce_carbs", "no_sugar"],
      "water_goal": 8
    },
    
    "exercise_plan": {
      "exercises": [
        {
          "name": "Morning Walk/Jog",
          "type": "cardio",
          "duration": 30,
          "time": "06:30",
          "difficulty": "beginner",
          "instructions": "First 10 min: walk normal pace...",
          "show_video": true
        },
        {
          "name": "Push-ups",
          "type": "strength",
          "sets": 3,
          "reps": 20,
          "difficulty": "beginner",
          "show_modifications": true,
          "safety_warning": null
        }
      ],
      "focus": "cardio_and_core",
      "days_per_week": 5
    }
  }
}
```

---

### **3. Save User Plan API** (After Signup)

**Endpoint**: `POST /api/user/save-plan`

**Purpose**: Save the generated plan to user's account after signup

**Request**:
```json
{
  "user_id": "firebase_user_id",
  "user_config": { ... } // The plan from generate-plan API
}
```

**Response**:
```json
{
  "success": true,
  "message": "Plan saved successfully"
}
```

---

## 🤖 **AI SERVICE IMPLEMENTATION**

You'll need to integrate with an AI model (OpenAI GPT-4, Claude, or Gemini):

### **Option 1: OpenAI GPT-4** (Recommended)
- **Best for**: Natural conversation, good at extracting data
- **Cost**: ~$0.03 per 1K tokens (input), $0.06 per 1K tokens (output)
- **API Key**: Get from OpenAI

### **Option 2: Google Gemini**
- **Best for**: Free tier available, good performance
- **Cost**: Free tier: 60 requests/min
- **API Key**: Get from Google AI Studio

### **Option 3: Anthropic Claude**
- **Best for**: Very good at following instructions
- **Cost**: Similar to GPT-4
- **API Key**: Get from Anthropic

---

## 📝 **BACKEND STRUCTURE**

### **Recommended Stack**:
- **Node.js + Express** (or Python + FastAPI)
- **Firebase Firestore** (for storing user plans)
- **OpenAI/Gemini API** (for AI chat)

### **Database Schema** (Firestore):

```
users/
  {userId}/
    profile: { name, email, ... }
    config: { goal_type, diet_plan, exercise_plan, ... }
    progress: { weight_logs, workout_logs, ... }
    
temp_plans/
  {sessionId}/
    config: { ... } // Temporary plan before signup
    created_at: timestamp
    expires_at: timestamp
```

---

## 🔑 **ENVIRONMENT VARIABLES NEEDED**

```env
# AI Service
OPENAI_API_KEY=sk-...
# OR
GEMINI_API_KEY=...

# Firebase
FIREBASE_SERVICE_ACCOUNT_KEY=...

# App
PORT=3000
NODE_ENV=production
```

---

## 📱 **FLUTTER SIDE (Already Done)**

✅ Onboarding Slides Screen
✅ AI Chat Screen (needs API integration)
✅ Plan Summary Screen
✅ Routing setup
✅ Provider setup

**What's Left**:
1. Connect AI Chat Screen to your API
2. Call Generate Plan API after chat completes
3. Save plan to Firestore after signup

---

## 🎯 **NEXT STEPS**

### **Step 1**: Build AI Chat API
- Set up Node.js/Python backend
- Integrate OpenAI/Gemini
- Create chat endpoint
- Test with Postman

### **Step 2**: Build Generate Plan API
- Create plan generation logic
- Use AI to customize plans based on user data
- Return structured JSON

### **Step 3**: Connect Flutter to APIs
- Update `AiService` in Flutter
- Call APIs from `AiChatScreen`
- Save plan to Firestore after signup

### **Step 4**: Test Full Flow
- Test onboarding → chat → plan → signup → dashboard

---

## 💡 **SAMPLE AI PROMPT** (For Backend)

```javascript
const systemPrompt = `
You are a fitness coach AI. Your job is to:
1. Ask questions to understand the user's fitness goals
2. Extract key information: age, gender, goal, lifestyle, diet, exercise level
3. Be conversational and friendly
4. Ask follow-up questions to get complete information

When you have enough information, respond with:
{
  "is_complete": true,
  "extracted_data": { ... }
}
`;

const userMessage = "30 male, belly fat, eat 2 parathas morning...";

const response = await openai.chat.completions.create({
  model: "gpt-4",
  messages: [
    { role: "system", content: systemPrompt },
    { role: "user", content: userMessage }
  ]
});
```

---

## 📊 **COST ESTIMATION**

### **Per User Onboarding**:
- AI Chat: ~5-10 messages = ~$0.05-0.10
- Plan Generation: 1 request = ~$0.02-0.05
- **Total**: ~$0.10-0.15 per user

### **For 1000 Users**:
- **Cost**: ~$100-150/month

**Tip**: Use caching and templates to reduce AI calls!

---

## ✅ **READY TO BUILD?**

Let me know when you want to:
1. Set up the backend
2. Integrate AI APIs
3. Connect Flutter to backend
4. Test the full flow

I can help you with any of these steps! 🚀
