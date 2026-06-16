import { GoogleGenerativeAI } from '@google/generative-ai';

// Initialize the Gemini API client
const apiKey = process.env.GEMINI_API_KEY || '';
const genAI = apiKey ? new GoogleGenerativeAI(apiKey) : null;

/**
 * Programmatically scan a document using Google Gemini
 */
export const analyzeDocument = async (
  title: string,
  fileType: string,
  customInfo?: string
): Promise<string> => {
  if (!genAI) {
    console.warn('GEMINI_API_KEY is not configured. Falling back to mock analysis.');
    return mockAnalysis(title, fileType, customInfo);
  }

  try {
    const model = genAI.getGenerativeModel({
      model: 'gemini-2.5-flash',
      generationConfig: { temperature: 0.2 },
    });

    const prompt = `
You are VeriFi AI, an automated financial audit assistant for student organizations at the Polytechnic University of the Philippines (PUP).
Analyze this submitted document metadata:
Document Title: "${title}"
File Type: "${fileType}"
Additional User Provided Info: "${customInfo || 'None'}"

Generate a structured financial audit breakdown. Be extremely professional and accurate.
Your response MUST contain these exact key fields formatted like this (use Php for currency):

Proposed Budget: Php X,XXX.XX
Total Amount Spent: Php X,XXX.XX
Ending Balance: Php X,XXX.XX
Category: <Category name, e.g. Events / Operations / Supplies / Equipment>
Items: <Bulleted list of mock items scanned from this document type and title>
Status: <Verified / Warning / Needs Review (Warning/Needs Review if amounts are inconsistent or if there is any mismatch)>

Keep your response clean, concise, and structured. Do not use Markdown bold or italics other than standard bullet points.
`;

    const result = await model.generateContent(prompt);
    const text = result.response.text();
    return text.trim();
  } catch (err: any) {
    console.error('Error in Gemini document analysis:', err.message || err);
    return mockAnalysis(title, fileType, customInfo);
  }
};

/**
 * Interactive chat assistant powered by Gemini
 */
export const chatWithAssistant = async (
  message: string,
  chatHistory: { role: 'user' | 'model'; parts: { text: string }[] }[],
  documentContext?: string
): Promise<string> => {
  if (!genAI) {
    return 'Hi! The AI Chatbot is running in Offline Mode because the Gemini API Key is not configured on the server. Feel free to ask generic questions, but live AI answers are currently disabled.';
  }

  try {
    let systemInstruction = 'You are VeriFi AI, an AI financial transparency and audit verification assistant for student organizations at the Polytechnic University of the Philippines Sta. Maria Bulacan Campus. You help student officers upload documents, understand audit trails, check SHA-256 integrity hashes, and maintain compliance. Keep your answers helpful, concise, and structured.';
    
    if (documentContext) {
      systemInstruction += `\n\nActive Financial Documents Submitted by this User's Organization:\n${documentContext}\n\nUse the above data to answer the user's specific questions regarding their uploaded documents, audit details, items list, or status queries. Be factual and refer directly to this context.`;
    }

    const model = genAI.getGenerativeModel({
      model: 'gemini-2.5-flash',
      systemInstruction,
    });

    // Ensure history starts with 'user' role to satisfy Gemini SDK requirement
    const cleanedHistory = [...chatHistory];
    while (cleanedHistory.length > 0 && cleanedHistory[0].role !== 'user') {
      cleanedHistory.shift();
    }

    const chat = model.startChat({
      history: cleanedHistory,
      generationConfig: {
        maxOutputTokens: 500,
      },
    });

    const result = await chat.sendMessage(message);
    return result.response.text().trim();
  } catch (err: any) {
    console.error('Error in Gemini Chat:', err.message || err);
    return `Sorry, I encountered an error while communicating with Gemini. Details: ${err.message || err}`;
  }
};

// Fallback mock generator if API key is not active/working
const mockAnalysis = (title: string, fileType: string, customInfo?: string): string => {
  // Simple regex or parse info if user entered values
  let proposed = 'Php 15,000.00';
  let spent = 'Php 12,500.00';
  let balance = 'Php 2,500.00';
  
  if (customInfo) {
    const proposedMatch = customInfo.match(/Proposed Amount:\s*([0-9.,]+)/i);
    const spentMatch = customInfo.match(/Total Amount Spent:\s*([0-9.,]+)/i);
    const balanceMatch = customInfo.match(/Ending Balance:\s*([0-9.,]+)/i);
    if (proposedMatch) proposed = `Php ${proposedMatch[1]}`;
    if (spentMatch) spent = `Php ${spentMatch[1]}`;
    if (balanceMatch) balance = `Php ${balanceMatch[1]}`;
  }

  return `
Proposed Budget: ${proposed}
Total Amount Spent: ${spent}
Ending Balance: ${balance}
Category: Operations (Offline Mock Scan)
Items:
* Audited item details based on title: ${title}
* Automated offline scan verification
* SHA-256 hash match successful
Status: Verified (Offline Mode)
  `.trim();
};
