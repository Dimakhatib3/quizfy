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
Each question must have exactly 2 options only.
The true/false words MUST be in the SAME language as the uploaded text.
Examples:
Arabic: صحيح / خطأ
Turkish: Doğru / Yanlış
French: Vrai / Faux
English: True / False
Do NOT use English unless the uploaded text is English.
`;
      } else {
        typeInstructions = `
Generate a mix of multiple choice and true/false questions.

Rules:
- Multiple choice questions must have exactly 4 different options.
- True/false questions must use the SAME language as the uploaded text.
- Do NOT use English true/false unless the uploaded text is English.
- Do NOT repeat options.
`;
      }

      const prompt = `
Generate a ${difficulty} level quiz from this text.

VERY IMPORTANT LANGUAGE RULES:
- Detect the language of the uploaded text automatically.
- Generate EVERYTHING in the SAME language as the uploaded text.
- Questions must match the same language.
- Options must match the same language.
- Answers must match the same language.
- NEVER mix languages.
- If uploaded text is Arabic, everything must be Arabic.
- If uploaded text is Turkish, everything must be Turkish.
- If uploaded text is French, everything must be French.
- This applies to ANY language.

QUIZ SETTINGS:
- Number of questions: ${questionCount}
- Selected type: ${questionType}

${typeInstructions}

DIFFICULTY RULES:
- Easy = simple direct questions
- Medium = moderate understanding
- Hard = deeper understanding

OUTPUT RULES:
- Return ONLY valid JSON
- No markdown
- No explanation
- No code blocks
- The answer must exactly match one option

JSON format:
[
  {
    "question": "...",
    "options": ["...", "..."],
    "answer": "..."
  }
]

TEXT:
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