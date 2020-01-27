using System;
using System.Collections;
using System.Xml;
using System.Threading.Tasks;
using Nethereum.Web3;
using Nethereum.Hex.HexTypes;
using Nethereum.RPC.Eth.DTOs;
using System.Runtime.ExceptionServices;
using System.Collections.Generic;

namespace QuorumResults
{
    public class MultiDimDictList : Dictionary<ExceptionDispatchInfo, string> { }

    class Program
    {
        public static MultiDimDictList errors = new MultiDimDictList(); //Keeps all the hashes that failed       
        static void Main(string[] args)
        {
            string path = @"C:\Users\jsveistrup\source\repos\QuorumResults\QuorumResults\";
            string fileName = "5slaves_1000users_puretrans-200003-300002_1.xml";
            string outputFileName = "1000users_puretrans_part7";
            string nodeIp = "51.141.118.214";

            if (args.Length != 0)
            {
                path = args[0];
                fileName = args[1];
                outputFileName = args[2];
                nodeIp = args[3];
            }
            else
            {
                Console.WriteLine("No args has been inputed. Defaults loaded.");
            }
            
            
            Console.WriteLine("Starting: " + DateTime.Now);

            ArrayList inputs = getHashsesAndTimestamps(path + fileName);
            ArrayList results = new ArrayList();
             

            var web3 = new Web3("http://"+nodeIp+":22000");

            Console.WriteLine("Number of hashses found: " + inputs.Count.ToString());

            /*loops through all hashes in the result file and prepares the output array*/
            foreach (Result rsObj in inputs)
            {
                Boolean skipToNextItem = false;
                HexBigInteger hexBlockNum = getBlockNum(rsObj.hash, web3).Result;
                if (hexBlockNum != null)
                {
                    rsObj.blockNumber = (int)hexBlockNum.ToUlong();

                }
                else
                {
                    continue; //Error, and therefor skip to next item
                }
                

                /*Check if the block already has been retrieved */
                foreach (Result obj in results)
                {
                    if(obj.blockNumber == rsObj.blockNumber)
                    {
                        rsObj.txPerBlock = obj.txPerBlock;
                        rsObj.minedTimestamp = obj.minedTimestamp;
                        break;
                    }
                    else
                    {
                        
                        BlockWithTransactions bc = getTransactions(hexBlockNum, web3).Result;
                        if(bc != null)
                        {
                            rsObj.txPerBlock = bc.TransactionCount();
                            ulong ts = bc.Timestamp.ToUlong() * 1000; //multipies with 1000 to match format of sent timestamp
                            rsObj.minedTimestamp = ts.ToString();
                        }
                        else
                        {
                            skipToNextItem = true;
                            break;
                        }
                            
                    }

                }

                //First time
                if (results.Count == 0)
                {
                    BlockWithTransactions bc = getTransactions(hexBlockNum, web3).Result;
                    rsObj.txPerBlock = bc.TransactionCount();
                    ulong ts = bc.Timestamp.ToUlong() * 1000; //multipies with 1000 to match format of sent timestamp
                    rsObj.minedTimestamp = ts.ToString();
                }

                if (!skipToNextItem)
                {
                    results.Add(rsObj);
                    writeToFile(rsObj, path, outputFileName);
                    Console.WriteLine("Count of results: " + results.Count.ToString() + ". Wrote to file: " + DateTime.Now + ": " + rsObj.hash + ", " + rsObj.sendTimestamp + ", " + rsObj.minedTimestamp + ", " + rsObj.blockNumber + ", " + rsObj.txPerBlock);
                }
                else
                {
                    Console.WriteLine("Error: " + rsObj.hash);
                }
            }

            Console.WriteLine("End: " + DateTime.Now);
        }


        public static ArrayList getHashsesAndTimestamps(string filePath)
        {
            ArrayList results = new ArrayList();

            XmlDocument doc = new XmlDocument();
            doc.Load(filePath);

            foreach (XmlNode node in doc.DocumentElement.ChildNodes)
            {
                
                /*Getting the timestamp*/
                
                string ts = node.Attributes.GetNamedItem("ts").Value;

                /*Getting the Hash from the XML*/
                
                string text = node.ChildNodes.Item(0).InnerText;
                int start = node.ChildNodes.Item(0).InnerText.IndexOf("0x");

                string hash = node.ChildNodes.Item(0).InnerXml.Substring(start, (text.Length-start-3));
                Result rs = new Result(hash, ts, "", 0, 0);
                results.Add(rs);                
            }

            return results;
        }

        public static async Task<HexBigInteger> getBlockNum(string hash, Web3 web3)
        {
            ExceptionDispatchInfo capturedException = null;
            try { 
                var blockNum = await web3.Eth.Transactions.GetTransactionReceipt.SendRequestAsync(hash);

                while (blockNum == null)
                {
                    System.Threading.Thread.Sleep(5000);
                    Console.WriteLine("BlockNum 5000 ms");
                }
                return blockNum.BlockNumber;
            }
            catch(Exception ex)
            {
                capturedException = ExceptionDispatchInfo.Capture(ex);
                errors.Add(capturedException, hash);
                return null;
            }
            
           

        }

        public static async Task<BlockWithTransactions> getTransactions(HexBigInteger blockNumber, Web3 web3)
        {
            var blockTransactions = await web3.Eth.Blocks.GetBlockWithTransactionsByNumber.SendRequestAsync(blockNumber);
            ExceptionDispatchInfo capturedException = null;
            try
            {
                while (blockTransactions == null)
                {
                    System.Threading.Thread.Sleep(5000);
                    Console.WriteLine("Block count 5000 ms");
                }

                return blockTransactions;
            }
            catch (Exception ex)
            {
                capturedException = ExceptionDispatchInfo.Capture(ex);
                errors.Add(capturedException, blockNumber.ToUlong().ToString());
                return null;
            }
        }

        public static void writeToFile(Result rs, string path, string fileName)
        {
            using (System.IO.StreamWriter file = new System.IO.StreamWriter(path + ""+fileName+"-res.txt", true))
            {
                //hash, timestamp blockchain recieved tx, timestamp blockchain tx mined, blocknumber, tx per block
                //0x7e11ce95debd0c812df781cff745196405f518e75b15302d2f6df90f9982c86e, 1576245061855, 1576245447000, 53496, 13
                file.WriteLine(rs.hash + ", " + rs.sendTimestamp + ", " + rs.minedTimestamp + ", " + rs.blockNumber + ", " + rs.txPerBlock);
            }
        }

    }


    class Result
    {

        //hash, timestamp blockchain recieved tx, timestamp blockchain tx mined, blocknumber, tx per block
        //0x7e11ce95debd0c812df781cff745196405f518e75b15302d2f6df90f9982c86e, 1576245061855, 1576245447000, 53496, 13

        
        public string hash { get; set; }
        public string sendTimestamp { get; set; }
        public string minedTimestamp { get; set; }
        public int blockNumber { get; set; }
        public int txPerBlock { get; set; }

        public Result(string parHash, string parSendTimestamp, string parMinedTimestamp, int parBlockNumber, int parTxPerBlock)
        {
            hash = parHash;
            sendTimestamp = parSendTimestamp;
            minedTimestamp = parMinedTimestamp;
            blockNumber = parBlockNumber;
            txPerBlock = parTxPerBlock;
        }

        


    }
}
