import Text.Parsec.Prim
import Text.Parsec.Combinator
import Text.Parsec.ByteString
import Text.Parsec.Char
import Data.List
import Data.Function (on)

data Turn = LeftTurn | RightTurn deriving (Show, Eq)
data Instruction = Instruction Turn Int deriving (Show, Eq)

turn :: Parser Turn
turn = (char 'L' >> return LeftTurn) 
    <|> (char 'R' >> return RightTurn)
    <?> "direction"
    
instruction :: Parser Instruction
instruction = do t <- turn
                 i <- many digit
                 return $ Instruction t (read i)
    <?> "instruction"

data Direction = North | South | East | West deriving (Show, Eq)

applyTurn :: Turn -> Direction -> Direction
applyTurn LeftTurn North = West
applyTurn LeftTurn West  = South
applyTurn LeftTurn South = East
applyTurn LeftTurn East  = North
applyTurn RightTurn North = East
applyTurn RightTurn East  = South
applyTurn RightTurn South = West
applyTurn RightTurn West  = North

offset :: (Int, Int) -> Direction -> Int -> (Int, Int)
offset (x, y) North n = (x, y + n)
offset (x, y) South n = (x, y - n)
offset (x, y) East  n = (x + n, y)
offset (x, y) West  n = (x - n, y)

data Position = Position { location :: (Int, Int), direction :: Direction }
    deriving (Eq, Show)
  
steps :: Position -> Instruction -> [Position]
steps (Position location facing) (Instruction turn n) = 
    do i <- [1..n]
       let newFacing = applyTurn turn facing
       let newLocation = offset location newFacing i
       return $ Position newLocation newFacing

followPath :: Position -> [Instruction] -> [Position]
followPath _ [] = []
followPath pos (instr:instrs) = let walk = steps pos instr
                                in walk ++ followPath (last walk) instrs
                       
-- drops first occurance of each element                          
revisits :: [Position] -> [Position]
revisits x = x \\ nubBy ((==) `on` location) x
        
taxiDist :: Position -> Int
taxiDist (Position (x, y) _) = abs x + abs y
          
main = do input <- parseFromFile parser "input.txt"
          case input of
              Left error -> putStrLn $ "invalid input: " ++ show error
              Right instrs -> let path = followPath (Position (0, 0) North) instrs
                                  dest = last path
                                  firstRevisit = (head . revisits) path
                              in do putStrLn "taxicab distance:"
                                    putStrLn $ "  destination: " ++ show (taxiDist dest)
                                    putStrLn $ "  first revisit: " ++ show (taxiDist firstRevisit)

    where parser = instruction `sepBy` (char ',' >> spaces)
    
    