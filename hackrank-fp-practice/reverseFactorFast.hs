{-# LANGUAGE BangPatterns #-}

import Control.Applicative
import Control.Monad
import Data.Array
import qualified Data.List as L
import qualified Data.Map as M

import Debug.Trace (trace)

type Path   = M.Map Int Int
type Queue  = [Int]
type Buffer = [Int]

solve :: Int -> [Int] -> Queue -> Path -> Path
solve _ _ [] !p = p
solve !n !mu !q !p
  | n `M.member` p          = p
  | n `M.member` exp        = M.insert n (M.findWithDefault (-1) n exp) p
  | n < fst (M.findMin exp) = M.empty
  | otherwise               = solve n mu nq np
  where
    go x   = map (\y -> (x*y, x)) mu
    exp    = M.fromListWith min (concatMap go q)
    nq     = M.keys (M.difference exp p)
    np     = M.union p $ exp

backTrack :: Path -> Int -> Buffer -> IO ()
backTrack _ (-1) b  = putStrLn $ unwords (map show b)
backTrack p u !b =
  case M.lookup u p of
    Just  v   -> backTrack p v (u:b)
    Nothing   -> putStrLn "-1"

main :: IO ()
main = do
  [n, _] <- map read . words <$> getLine
  as     <- map read . words <$> getLine
  let mult = L.sort (L.nub as)
  let path = solve n mult [1] $ M.singleton 1 (-1)
  backTrack path n []