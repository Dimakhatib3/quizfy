const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const OpenAI = require("openai");

const openaiApiKey = defineSecret("OPENAI_API_KEY");

exports.generateQuiz = onRequest(
  { secrets: [openaiApiKey], invoker: "public" },
  async (req, res) => {
    try {
      const text = req.body.text;
      const difficulty = req.body.difficulty || "Easy";
      const questionType = req.body.questionType || "Multiple Choice";
      const questionCount = req.body.questionCount || 10;

      if (!text || text.trim() === "") {
        res.status(400).send("Missing text");
        return;
      }

      let typeInstructions = "";

      if (questionType === "Multiple Choice") {
        typeInstructions = `
Generate ONLY multiple choice questions.
Do NOT generate any true/false questions.
Each question must have exactly 4 different options.
Only ONE option must be correct.
`;
      } else if (questionType === "True-False") {
        typeInstructions = `
Generate ONLY true/false questions.
Do NOT generate any multiple choice questions.
Each question must have exactly these 2 options only:
["True", "False"]
Do NOT repeat options.
Do NOT use 4 options.
`;
      } else {
        typeInstructions = `
Generate a mix of multiple choice and true/false questions.

Rules:
- Multiple choice questions must have exactly 4 different options.
- True/false questions must have exactly these 2 options only:
  ["True", "False"]
- Do NOT repeat options.
`;
      }

      const prompt = `
Generate a ${difficulty} level quiz from this text.

IMPORTANT LANGUAGE RULES:
- Detect the language of the input text automatically.
- Generate ALL questions, options, and answers in the SAME language as the input text.
- Do NOT switch languages.
- If the text is Arabic, the quiz must be fully in Arabic.
- If the text is Turkish, the quiz must be fully in Turkish.
- If the text is French, the quiz must be fully in French.
- This rule applies to ANY language in the uploaded text.

QUIZ SETTINGS:
- Number of questions: ${questionCount}
- Selected type: ${questionType}

${typeInstructions}

DIFFICULTY RULES:
- Easy: simple direct questions
- Medium: moderate understanding
- Hard: deeper and more challenging questions

OUTPUT RULES:
- Return ONLY valid JSON
- Do NOT add explanation
- Do NOT add markdown
- Do NOT add code fences
- The "answer" must exactly match one item from "options"
- Do NOT mix question types unless selected type is "Both"

Return in this exact JSON format:
[
  {
    "question": "...",
    "options": ["...", "...", "...", "..."],
    "answer": "..."
  }
]

IMPORTANT FORMAT RULES:
- If the question is True/False, options must be exactly 2 items only, in the same language as the input text
- If the question is Multiple Choice, options must be exactly 4 items
- All options must be different
- The answer must exactly match one option

Text:
${text}
`;

      const openai = new OpenAI({
        apiKey: openaiApiKey.value(),
      });

      const completion = await openai.chat.completions.create({
        model: "gpt-4.1-mini",
        messages: [
          {
            role: "user",
            content: prompt,
          },
        ],
        temperature: 0.4,
      });

      const reply = completion.choices[0].message.content;

      res.status(200).send(reply);
    } catch (error) {
      console.error("FULL ERROR:", error);
      res.status(500).send(error.message || "Error generating quiz");
    }
  }
);